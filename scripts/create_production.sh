#!/bin/bash
# This script is used for deploying all images for the
# DockerHub Automated Build Repositories
set -e

display_help() {
  echo "Usage: $0 image_directory wrapper_directory tag"
  echo
  echo "Creates a production directory containing the docker context for DockerHub auto build"
  echo
  echo "base_image_dir    - path to the directory where each subdirectory contains the Docker"
  echo "                    context for the base images"
  echo "app_image_dir     - path to the directory where each subdirectory is a Docker context"
  echo "                    for the application images"
  echo "wrapper_directory - path to the directory to the wrapper directory"
  echo "tag               - tag to be used for the base images (e.g. v0.1.0, latest, ...)"
  echo
  echo "Example:"
  echo "  ./create_production.sh ../base_images ../images ../wrapper latest"
}


if [ -z "$1" ]; then
    echo "Need path to the directory that holds all the base images"
    display_help
    exit 1
fi

if [ -z "$2" ]; then
    echo "Need path to the directory that holds all the application images"
    display_help
    exit 1
fi

if [ -z "$3" ]; then
    echo "Need directory for the front-end wrapper (e.g. ../wrapper)"
    display_help
    exit 1
fi

if [ -z "$4" ]; then
    echo "Please specify the tag for the base images"
    display_help
    exit 1
fi

# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# production directory
production_dir=$DIR/../production

# The directory that contains all base images
base_images_dir=$PWD/${1%/}

# The directory that contains all application images
app_images_dir=$PWD/${2%/}

# The directory that provides the front-end/back-end support for remote access
wrapper_dir=$PWD/$3

# Tag for the base images
tag=$4

echo "Removing "$production_dir

$DIR/create_production_base.sh $base_images_dir $wrapper_dir $production_dir
$DIR/create_production_app.sh $app_images_dir $tag $production_dir

