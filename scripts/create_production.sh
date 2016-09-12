#!/bin/bash
# This script is used for deploying all images for the
# DockerHub Automated Build Repositories
set -e
# The path to this script file
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Import common functions
. functions.sh

display_help() {
  echo "Usage: $0 config_file"
  echo
  echo "Creates a production directory containing the docker context for DockerHub auto build"
  echo
  echo "Example:"
  echo "  ./create_production.sh build.conf"
}

if [ -z "$1" ]; then
    echo "Need path to the config file."
    display_help
    exit 1
fi

config_file=$1

$DIR/create_production_base.sh $config_file
$DIR/create_production_app.sh $config_file
