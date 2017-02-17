#!/bin/bash
# This script is used for deploying application images for its
# DockerHub Automated Build Repository.
set -e
# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LABEL_DOMAIN=eu.simphony-project

. $DIR/functions.sh

display_help() {
  echo "Usage: $0 path/to/build.conf"
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
operating_dir=`dirname $config_file`/

# The directory that contains all base images
extract_key "$config_file" "app_dir"
if [ -z "$RESULT" ]; then
    echo "Need app_dir in config file"
    display_help
    exit 1
fi
app_dir=$operating_dir/${RESULT%/}

extract_key "$config_file" "base_tag"
if [ -z "$RESULT" ]; then
    echo "Need base_tag in config file"
    display_help
    exit 1
fi
tag=$RESULT

# production directory
extract_key "$config_file" "production_dir"
if [ -z "$RESULT" ]; then
    echo "Need production_dir in config file"
    display_help
    exit 1
fi
production_dir=$operating_dir/${RESULT%/}
image_name=`basename $app_dir`

# One sub-directory for each image
echo "Removing "$production_dir/$image_name
rm -rf $production_dir/$image_name

echo "Creating "$production_dir/$image_name
mkdir -p $production_dir/$image_name
# Copy files from the image directory to the production sub-directory
echo "Copying files from " $app_dir " to " $production_dir/$image_name
rsync -a --exclude='*~' $app_dir/* $production_dir/$image_name/

# Replace the tag in the docker file FROM entry
sed 's/^FROM \([^:]*\)/FROM \1:'$base_tag'/g' $production_dir/$image_name/Dockerfile > $production_dir/$image_name/Dockerfile.build

# if there's an icon, base encode it and use it.
if [ -e $production_dir/$image_name/icon_128.png ]; then
    b64encode $production_dir/$image_name/icon_128.png
    echo "LABEL ${LABEL_DOMAIN}.docker.icon_128=\"${RESULT}\"" >>$production_dir/$image_name/Dockerfile.build
fi

mv $production_dir/$image_name/Dockerfile.build $production_dir/$image_name/Dockerfile

echo "***********************************************************************"
echo "Now all the files for Docker build are in $production_dir/$image_name"
echo "***********************************************************************"
