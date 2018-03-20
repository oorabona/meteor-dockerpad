#!/bin/bash
set -e
source scripts/common.sh

export BASE_IMAGE=${1:-"oorabona/meteor-dockerpad"}
export TAG=${2:-prod}

DC=$(which docker-compose)

if [ "$DC" == "" ]
then
  p "This program requires 'docker-compose' to be seen in your PATH !"
  exit 1
fi

if [ $# -eq 0 ]
then
  printf "FYI usage is: $0 [base image name] [tag]\nWhere:\n"
  printf "\t[base image name] is your possibly customized Docker image (default is $BASE_IMAGE)\n"
  printf "\t[tag] is the production related tag (default is $TAG)\n"
  printf "Note: tag is used when building production image. Development will always be tagged 'dev'.\n"
fi

p "Building image" $BASE_IMAGE "for target development environment."
$DC build dev

p "Building image" $BASE_IMAGE "for target production environement with tag '" $TAG "'"
$DC build prod

p "All done!\n"
p "When you are ready, you can push them to the registry by running:"
p "docker push $BASE_IMAGE:dev"
p "docker push $BASE_IMAGE:$TAG"
