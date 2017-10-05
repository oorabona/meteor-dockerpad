#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

if [ -f $APP_SOURCE_DIR/launchpad.conf ]; then
  source <(grep INSTALL_MONGO $APP_SOURCE_DIR/launchpad.conf)
fi

if [ "$INSTALL_MONGO" == "true" ]; then
  p "Installing MongoDB..."
  apt install -y mongodb
fi
