#!/bin/bash
# This script is used for deploying application images for its
# DockerHub Automated Build Repository.
set -e
# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LABEL_DOMAIN=eu.simphony-project

. functions.sh

display_help() {
  echo "Usage: $0 build.conf"
  echo
  echo "Creates a production directory containing the docker context for DockerHub auto build"
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
extract_key "$DIR/$config_file" "app_images_dir"
if [ -z "$RESULT" ]; then
    echo "Need app_images_dir in config file"
    display_help
    exit 1
fi
app_images_dir=$DIR/${RESULT%/}

extract_key "$DIR/$config_file" "tag"
if [ -z "$RESULT" ]; then
    echo "Need tag in config file"
    display_help
    exit 1
fi
tag=$RESULT

# production directory
extract_key "$DIR/$config_file" "production_dir"
if [ -z "$RESULT" ]; then
    echo "Need production_dir in config file"
    display_help
    exit 1
fi
production_dir=$DIR/${RESULT%/}

# Construct docker context for production
for image in `ls -d $app_images_dir/*/`; do
    image_name=`basename $image`

    # One sub-directory for each image
    echo "Removing "$production_dir/$image_name
    rm -rf $production_dir/$image_name

    echo "Creating "$production_dir/$image_name
    mkdir -p $production_dir/$image_name

    # Copy files from the image directory to the production sub-directory
    echo "Copying files from " $app_images_dir/$image_name
    rsync -a --exclude='*~' $app_images_dir/$image_name/* $production_dir/$image_name/

    # Replace the tag in the docker file FROM entry
    sed 's/^FROM \([^:]*\)/FROM \1:'$tag'/g' $production_dir/$image_name/Dockerfile > tmp

    mv tmp $production_dir/$image_name/Dockerfile
done

echo "***********************************************************************"
echo "Now all the files for Docker build are ready in $production_dir"
echo "Please push this directory to an orphan branch"
echo "***********************************************************************"
