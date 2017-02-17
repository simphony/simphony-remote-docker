#!/bin/bash
# This scripts rebuilds the whole set of containers. Be careful because it invalidates previous
# containers already stored in the docker server.

# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/functions.sh

# All wrapped docker images will have the name $IMAGE_PREFIX/image_name
# for them to be identified
IMAGE_PREFIX=simphonyproject

display_help() {
  echo "Usage: $0 config_file"
  echo
  echo "Builds all the application containers from the production directory specified in the configuration file."
}

if [ -z "$1" ]; then
    echo "Need path to the config file"
    echo 
    display_help
    exit 1
fi

config_file=$1
operating_dir=`dirname $config_file`/

extract_key "$config_file" "production_dir"
if [ -z "$RESULT" ]; then
    echo "Need production_dir in config file"
    display_help
    exit 1
fi
production_dir=$operating_dir/${RESULT%/}

# The directory that contains all base images
extract_key "$config_file" "app_dir"
if [ -z "$RESULT" ]; then
    echo "Need app_dir in config file"
    display_help
    exit 1
fi
app_dir=$operating_dir/${RESULT%/}
image_name=`basename $app_dir`

# There should be only one, but you never know
echo "Building "$image_name

$DIR/build_docker.sh $IMAGE_PREFIX $production_dir/$image_name
if test $? -ne 0; then
    echo "Error occurred while building $image_name. Exiting"
    exit
fi
