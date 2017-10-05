#!/bin/bash
set -e
source scripts/common.sh

export BASE_IMAGE=${1:-"oorabona/meteor-dockerpad"}
export TAG=$2

DC=$(which docker-compose)

if [ "$DC" == "" ]
then
  p "This program requires 'docker-compose' to be seen in your PATH !"
  exit 1
fi

if [ $# -eq 0 ]
then
  printf "FYI usage is: $0 [base image name] [tag]\nWhere:\n"
  printf "\t[base image name] is your possibly customized Docker image ('' if you want to keep it default)\n"
  printf "\t[tag] is the production related tag (can be latest or anything but 'dev')\n"
  printf "Note: tag is required if you want to build production image but in all cases 'dev' will be built.\n"
fi

p "Building image" $BASE_IMAGE "for target development environment."
$DC build dev

# If tag is set then we assume than we want to build also the 'production' image
if [[ "$TAG" != "" ]]
then
  p "Building image" $BASE_IMAGE "for target production environement with tag" $TAG
  $DC build prod
fi

p "All done!"
