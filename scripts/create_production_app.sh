#!/bin/bash
# This script is used for deploying application images for its
# DockerHub Automated Build Repository.
set -e

display_help() {
  echo "Usage: $0 image_directory tag production_dir"
  echo
  echo "Creates a production directory containing the docker context for DockerHub auto build"
  echo
  echo "image_directory  - path to the directory where each subdirectory is a Docker context"
  echo "tag              - tag to be used for the base images"
  echo "production_dir   - path to the directory where the output Docker context should be"
  echo
  echo "Example:"
  echo "  ./create_production_app.sh ../images latest"
}


if [ -z "$1" ]; then
    echo "Need path to the directory that holds all the images"
    display_help
    exit 1
fi

if [ -z "$2" ]; then
    echo "Please specify the tag for the base images"
    display_help
    exit 1
fi

if [ -z "$3" ]; then
    echo "Please specify the path to the production directory"
    display_help
    exit 1
fi

# The directory that contains all images
images_dir=$1

# Tag for the base images
tag=$2

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

    # Append wrapper's Dockerfile to the one for the image
    sed 's/^FROM \([^:]*\)/FROM \1:'$tag'/g' $production_dir/$image_name/Dockerfile > tmp
    mv tmp $production_dir/$image_name/Dockerfile
done

echo "***********************************************************************"
echo "Base images would be pulled from "$2
echo "Now all the files for Docker build are ready in "$production_dir
echo "Please push this directory to an orphan branch"
echo "***********************************************************************"
