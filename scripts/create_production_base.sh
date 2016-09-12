#!/bin/bash
# This script is used for deploying base images for its
# DockerHub Automated Build Repository.
set -e
# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. functions.sh

display_help() {
  echo "Usage: $0 build.conf"
  echo
  echo "Creates a production directory containing the docker context for DockerHub auto build."
  echo "Used for deploying base images with the remote access support already included."
  echo
}

if [ -z "$1" ]; then
    echo "Need path to the config file"
    echo
    display_help
    exit 1
fi

config_file=$1

# The directory that contains all base images
extract_key "$DIR/$config_file" "base_images_dir"
if [ -z "$RESULT" ]; then
    echo "Need base_images_dir in config file"
    display_help
    exit 1
fi
base_images_dir=$DIR/${RESULT%/}

# production directory
extract_key "$DIR/$config_file" "production_dir"
if [ -z "$RESULT" ]; then
    echo "Need production_dir in config file"
    display_help
    exit 1
fi
production_dir=$DIR/${RESULT%/}

# The directory that provides the front-end/back-end support for remote access
extract_key "$DIR/$config_file" "wrappers_dir"
if [ -z "$RESULT" ]; then
    echo "Need wrappers_dir in config file"
    display_help
    exit 1
fi
wrappers_dir=$DIR/${RESULT%/}

extract_key "$DIR/$config_file" "build_base"
if [ -z "$RESULT" ]; then
    echo "Need build_base in config file"
    display_help
    exit 1
fi
build_base=$RESULT

# Construct docker context for production
for entry in $build_base; do
    base_image_name=`echo $entry | cut -d':' -f1`
    wrapper_name=`echo $entry | cut -d':' -f2`
    final_image_name=${base_image_name}-${wrapper_name}

    # One sub-directory for each image
    echo "Removing "$production_dir/$final_image_name
    rm -rf $production_dir/$final_image_name
    echo "Creating "$production_dir/$final_image_name
    mkdir -p $production_dir/$final_image_name

    # Copy files from the image directory to the production sub-directory
    echo "Copying files from $base_images_dir/$base_image_name to $production_dir/$final_image_name/"
    rsync -a --exclude='*~' $base_images_dir/$base_image_name/* $production_dir/$final_image_name/

    echo "Copying files from $wrappers_dir/$wrapper_name to $production_dir/$final_image_name/"
    rsync -a --exclude='*~' $wrappers_dir/$wrapper_name/* $production_dir/$final_image_name/

    # Append wrapper's Dockerfile to the one for the image
    grep -ve '^FROM' $production_dir/$final_image_name/Dockerfile.template >> $production_dir/$final_image_name/Dockerfile
done

echo "***********************************************************************"
echo "Now all the files for Docker build are ready in $production_dir"
echo "***********************************************************************"
