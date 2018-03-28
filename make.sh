#!/bin/bash
set -e
source scripts/common.sh

export TAG=${1:-"dev slim"}
export BASE_IMAGE=${2:-"oorabona/meteor-dockerpad"}
DC=docker-compose
DC_BUILD_OPTS="--force-rm --no-cache"
DC_VERSION=1.19.0

# Kudos goes to https://gist.github.com/ziwon/9b6acf2dc09849729efc97d50d253f9e
parse_yaml() {
  local prefix=$2
  local s
  local w
  local fs
  s='[[:space:]]*'
  w='[a-zA-Z0-9_\-]*'
  fs="$(echo @|tr @ '\034')"
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
  awk -F"$fs" '{
  indent = length($1)/2;
  vname[indent] = $2;
  for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
          vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
          printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
      }
  }' | sed 's/_=/+=/g'
}

get_dc() {
  p "This program requires 'docker-compose' to be seen in your PATH !"
  read -p "Download ? [y/N]" dl
  dl=${dl,,}
  if [ "$dl" == "y" ]
  then
    command -v curl >/dev/null 2>&1 || { echo >&2 "I require 'curl' but it's not installed. Aborting."; exit 1; }
    curl -L https://github.com/docker/compose/releases/download/$DC_VERSION/docker-compose-`uname -s`-`uname -m` -o docker-compose
    chmod +x docker-compose
    if [ "$(id -u)" = "0" ]; then
      mv docker-compose /usr/local/bin
      p "docker-compose has been succesfully installed in /usr/local/bin !"
      DC=/usr/local/bin/docker-compose
    else
      p "We are not running as root so docker-compose has been installed in" $PWD
      DC=/usr/local/bin/docker-compose
    fi
  else
    echo >&2 "I require docker-compose but it's not installed. Aborting."
    exit 1
  fi
}

command -v docker-compose >/dev/null 2>&1 || get_dc

p "Found docker-compose ! :)"

if [ $# -eq 0 ]
then
  printf "FYI usage is: $0 [tag] [base image name]\nWhere:\n"
  printf "\t[tag] is the production related tag (default is to build 'dev' and 'slim', 'all' to build all !)\n"
  printf "\t[base image name] is your possibly customized Docker image (default is $BASE_IMAGE)\n"
fi

if [ "$TAG" == "all" ]
then
  # read yaml file
  TAG=$(parse_yaml docker-compose.yml | grep services |
  {
    while read l
    do
      echo "$l"|cut -d'_' -f2
    done
  } | uniq )
fi

echo $TAG|tr ' ' '\n'| {
  while read tag
  do
    p "Building image" $BASE_IMAGE "for target tagged '" $tag "'"
    $DC build $DC_BUILD_OPTS $tag
  done
}

p "All done!\n"
p "When you are ready, you can push them to the registry by running:"

echo $TAG|tr ' ' '\n'| {
  while read tag
  do
    echo "docker push $BASE_IMAGE:$tag"
  done
}
