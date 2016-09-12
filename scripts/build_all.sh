#!/bin/bash
# This scripts rebuilds the whole set of containers. Be careful because it invalidates previous
# containers already stored in the docker server.

# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. functions.sh

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

$DIR/build_base.sh $config_file
$DIR/build_app.sh $config_file
