#!/bin/bash
# Script for testing access an image locally using a web browser

set -e

display_help() {
  echo "Usage: $0 image_name env_file container_name"
  echo
  echo "Start and run a docker image and open a URL that points to the"
  echo "noVNC page of the container"
  echo
  echo "image_name      - name of the docker image to be tested"
  echo "env_file        - path to the environment file"
  echo "container_name  - name of the container created"
  echo
  echo "Example:"
  echo "  ./test_novnc_directly.sh simphonyproject/simphonic-mayavi ./env_file test"
}

function cleanup {
    echo "Cleaning up...";
    (docker stop $1 && docker rm $1) || (docker rm $1)
}

function start {
    docker run -d --name $3 --env-file=$2 -p 33000-35000:8888 $1
    sleep 2
}

if [ -z "$1" ]; then
    echo "Need the image name for testing"
    echo
    display_help
    exit 1
fi

if [ -z "$2" ]; then
    echo "Need the path to the environment file"
    echo
    display_help
    exit 1
fi

if [ -z "$3" ]; then
    echo "Need a name for the test container"
    echo
    display_help
    exit 1
fi


if test "`docker ps -a -f name=$3 | wc -l`" -gt 1; then
    read -p "$3 already exists.  Do you want to stop and/or remove it? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
	cleanup $3
	start $1 $2 $3
    else
	echo "Will test using the existing container."
	docker start $3; sleep 2
    fi
else
    start $1 $2 $3
fi

# Make sure the container is running
docker ps | grep $1 | grep $3
if test $? != 0; then
    echo "Failed to run $1"
    cleanup $3
    exit 1
fi

# Get id
container_id=`docker inspect -f "{{ .Id }}" $3`

# Get HostIp and HostPort
host_ip=`docker inspect --format '{{ (index (index .NetworkSettings.Ports "8888/tcp") 0).HostIp }}' $3`
host_port=`docker inspect --format '{{ (index (index .NetworkSettings.Ports "8888/tcp") 0).HostPort }}' $3`

# If the machine is not Linux, replace the ip with the docker VM IP
if [[ "`uname`" != 'Linux' ]]; then
    host_ip=`docker-machine ip`
fi

# Base user URL
JPY_BASE_USER_URL=`grep JPY_BASE_USER_URL $2 | awk -F'=' '{print $2}'`

# Complete URL for inspection
URL="http://${host_ip}:${host_port}${JPY_BASE_USER_URL}/containers/${container_id}"
echo $URL
open_path=$(which xdg-open || which gnome-open || which open) && exec "$open_path" "$URL"