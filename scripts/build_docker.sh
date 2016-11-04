#!/bin/bash
# Script that builds a given directory into a docker application image.

LABEL_DOMAIN=eu.simphony-project

function b64encode {
    if test "`which uuencode`" != ""; then
        RESULT=`uuencode -m $1 $1 | sed '1d;$d'| tr -d '\n'`
    elif test "`which base64`" != ""; then
        RESULT=`base64 -w 0 $1`
    else
        echo "Cannot find base64 encoder utility"
        exit 1
    fi
}

# All wrapped docker images will have the name $IMAGE_PREFIX/image_name
# for them to be identified

if [ $# -eq 2 ]; then
    # Basenaming to remove potential /
    IMAGE_TAG="$1/`basename $2`"
    DIR="$2"
elif [ $# -eq 1 ]; then
    IMAGE_TAG=`basename $1`
    DIR="$1"
else
    echo ""
    echo "Usage: "
    echo "$0 image_prefix directory"
    echo ""
    echo "   Builds an image from the contents in directory. "
    echo "   The resulting image will be tagged as 'image_prefix/directory'"
    echo ""
    echo "$0 directory"
    echo ""
    echo "   Builds an image from the contents in directory. "
    echo "   The resulting image will be tagged as 'directory'"
    exit 1
fi
    
pushd $DIR

cp Dockerfile Dockerfile.build

# if there's an icon, base encode it and use it.
if [ -e icon_128.png ]; then
    b64encode icon_128.png
    echo "LABEL ${LABEL_DOMAIN}.docker.icon_128=\"${RESULT}\"" >>Dockerfile.build
fi

docker build --rm -f Dockerfile.build -t $IMAGE_TAG .

status=$?

popd

if [[ $status != 0 ]]; then
    echo "Failed to build $IMAGE_TAG"
    exit $status
fi
