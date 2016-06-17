#!/bin/bash
# This script is used for building base images in ./base_images
# Usage: ./build_base.sh ./base_images/directory

PREFIX='simphony'

if [ "$1" = "" ]; then
    echo "Need docker directory name"
    exit 1
fi

# Basenaming to remove potential /
docker_name=`basename $1`

pushd $1

docker build --rm -f Dockerfile -t $PREFIX/$docker_name .

popd
