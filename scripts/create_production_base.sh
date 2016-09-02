#!/bin/bash
# This script is used for deploying base images for its
# DockerHub Automated Build Repository.
set -e

display_help() {
  echo "Usage: $0 image_directory wrapper_directory production_dir"
  echo
  echo "Creates a production directory containing the docker context for DockerHub auto build."
  echo "Used for deploying base images with the remote access support already included."
  echo "Docker context in the wrapper_directory is appended to those in the image_directory"
  echo
  echo "image_directory   - path to the directory where each subdirectory is a Docker context"
  echo "wrapper_directory - path to the directory to the wrapper directory"
  echo "production_dir   - path to the directory where the output Docker context should be"
  echo
  echo "Example:"
  echo "  ./create_production_app.sh ../base_images ../wrappers"
}

if [ -z "$1" ]; then
    echo "Need path to the directory that holds all the images"
    display_help
    exit 1
fi

if [ -z "$2" ]; then
    echo "Need directory for the front-end wrapper (e.g. ../wrapper)"
    display_help
    exit 1
fi

if [ -z "$3" ]; then
    echo "Please specify the path to the production directory"
    display_help
    exit 1
fi

# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The directory that contains all images
images_dir=$1

# The directory that provides the front-end/back-end support for remote access
wrapper_dir=$2

# production directory
production_dir=$3

# Construct docker context for production
for image in `ls -d $images_dir/*/`; do
    image_name=`basename $image`

    # One sub-directory for each image
    echo "Removing "$production_dir/$image_name
    rm -rf $production_dir/$image_name
    echo "Creating "$production_dir/$image_name
    mkdir -p $production_dir/$image_name

    # Copy files from the image directory to the production sub-directory
    echo "Copying files from " $images_dir/$image_name
    rsync -a --exclude='*~' $images_dir/$image_name/* $production_dir/$image_name/

    # Decide which kind of wrapper to use, according to the application type.
    if [ ! -e "$images_dir/$image_name/Metainfo" ]; then
        echo "ERROR: The specified image directory $images_dir/$image_name/ does not contain the required Metainfo file."
        echo "Cannot decide which wrapper type to use."
        continue
    fi

    wrapper_type=`cat "$images_dir/$image_name/Metainfo | grep "^wrapper" | cut -d'=' -f2`

    if [ -z "$wrapper_type" ]; then
        echo "ERROR: The $images_dir/$image_name/Metainfo does not contain a wrapper type specification"
        echo "Please add wrapper=wrapper_type in the file"
        continue
    fi

    if [ ! -e "$wrapper_dir/$wrapper_type/" ]; then
        echo "The wrapper type $wrapper_type does not exist in $wrapper_dir"
        exit 1
    fi

    echo "Using wrapper type $wrapper_type"

    # Copy files from wrapper
    echo "Copying files from " $wrapper_dir/$wrapper_type
    rsync -a --exclude='*~' $wrapper_dir/$wrapper_type/* $production_dir/$image_name/

    # Append wrapper Dockerfile to the one for the image
    grep -ve '^FROM' $production_dir/$image_name/Dockerfile.template >> $production_dir/$image_name/Dockerfile
done

echo "***********************************************************************"
echo "Now all the files for Docker build are ready in "$production_dir
echo "Please push this directory to an orphan branch"
echo "***********************************************************************"
