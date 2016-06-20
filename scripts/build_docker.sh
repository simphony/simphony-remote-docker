#!/bin/bash
# Support script for build_all.sh. You should not call this one directly.
# Builds the image of a single directory

# All wrapped docker images will have the name $IMAGE_PREFIX/image_name
# for them to be identified
IMAGE_PREFIX=simphonyproject
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


if [ -z "$1" ]; then
    echo "Need docker directory name"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Need directory for the front-end wrapper (e.g. ../wrapper)"
    exit 1
fi

# Basenaming to remove potential /
export IMAGE_NAME=`basename $1`

app_directory=$1
wrapper_directory=$2

# Work in a temporary directory
tmp_dir=`mktemp tmp.XXXXXXXXX`
rm -rf $tmp_dir
cp -rf $app_directory $tmp_dir

# Copy wrapper's file to the Docker context
# If there is any name conflict, the wrapper always has priority
cp -rf $wrapper_directory/* $tmp_dir/

#-------------------------------
# Build the image
#-------------------------------
pushd $tmp_dir

# if there's an icon, base encode it and use it.
if test -e icon_128.png; then
    b64encode icon_128.png
    label_opt="--label=\"${LABEL_DOMAIN}.docker.icon_128=${RESULT}\""
else
    label_opt=""
fi

# Append the Dockerfile.template from the wrapper to the current Dockerfile
grep -ve '^FROM' Dockerfile.template >> Dockerfile

docker build --rm -f Dockerfile -t $IMAGE_PREFIX/$IMAGE_NAME  $label_opt .

status=$?

popd

if [[ $status != 0 ]]; then
    echo "Failed to build $IMAGE_NAME"
    echo "You may check the Docker context in "$tmp_dir
    exit $status
fi

rm -rf $tmp_dir
