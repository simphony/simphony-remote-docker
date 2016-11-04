#!/bin/bash
# This scripts rebuilds the whole set of containers. Be careful because it invalidates previous
# containers already stored in the docker server.

# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. functions.sh

# All wrapped docker images will have the name $IMAGE_PREFIX/image_name
# for them to be identified
IMAGE_PREFIX=simphonyproject

display_help() {
  echo "Usage: $0 config_file"
  echo
  echo "Builds all the containers from the production directory specified in the configuration file."
}

if [ -z "$1" ]; then
    echo "Need path to the config file"
    echo 
    display_help
    exit 1
fi

config_file=$1

# production directory
extract_key "$DIR/$config_file" "production_dir"
if [ -z "$RESULT" ]; then
    echo "Need production_dir in config file"
    display_help
    exit 1
fi
production_dir=$DIR/${RESULT%/}

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
    echo "Building "$production_dir/$final_image_name

    $DIR/build_docker.sh $IMAGE_PREFIX $production_dir/$final_image_name
    if test $? -ne 0; then
        echo "Error occurred while building $production_dir/$final_image_name. Exiting"
        exit
    fi
done

