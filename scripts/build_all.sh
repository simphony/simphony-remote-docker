#!/bin/bash
# This scripts rebuilds the whole set of containers. Be careful because it invalidates previous
# containers already stored in the docker server.

# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]; then
    echo "Need path to the directory that holds all the images"
    exit 1
fi

wd=${1%/}

if [ -z "$2" ]; then
    echo "Need directory for the front-end wrapper (e.g. ../wrapper)"
    exit 1
fi

for image in `ls -d $wd/*/`; do
    echo "Building $image"
    $DIR/build_docker.sh $image $2
    if test $? -ne 0; then
        echo "Error occurred while building $image. Exiting"
        exit
    fi
done
