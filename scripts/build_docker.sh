#!/bin/bash
# Support script for build_all.sh. You should not call this one directly.
# Builds the image of a single directory

# All wrapped docker images will have the name $IMAGE_PREFIX/image_name
# for them to be identified
IMAGE_PREFIX=simphonyproject

if [ -z "$1" ]; then
    echo "Need docker directory name"
    exit 1
fi

# Basenaming to remove potential /
export IMAGE_NAME=`basename $1`


pushd $1

docker build --rm -f Dockerfile -t $IMAGE_PREFIX/$IMAGE_NAME .

status=$?

popd

if [[ $status != 0 ]]; then
    echo "Failed to build $IMAGE_NAME"
    exit $status
fi
