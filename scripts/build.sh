#!/usr/bin/env bash

set -e
source $BUILD_SCRIPTS_DIR/common.sh

# To avoid doing things twice, load our current configuration
if [ -f $BUILD_SCRIPTS_DIR/launchpad.conf ]; then
  p "Found previous configuration template, loading it."
  source $BUILD_SCRIPTS_DIR/launchpad.conf
else
  p "No previous configuration found. Saving configuration."
  cat << eof > $BUILD_SCRIPTS_DIR/launchpad.conf
INSTALL_PREREQUISITES=true
INSTALL_METEOR=$INSTALL_METEOR
METEOR_VERSION=$METEOR_VERSION
INSTALL_MONGO=$INSTALL_MONGO
INSTALL_NGINX=$INSTALL_NGINX
EXTRA_PREINSTALL_SCRIPT=$EXTRA_PREINSTALL_SCRIPT
EXTRA_POSTINSTALL_SCRIPT=$EXTRA_POSTINSTALL_SCRIPT
eof
fi

# If we have a specific project configuration file, overload our configuration
if [ -f $APP_SOURCE_DIR/launchpad.conf ]; then
  p "Using $APP_SOURCE_DIR/launchpad.conf configuration ..."
  source $APP_SOURCE_DIR/launchpad.conf
else
  p "Attention! No configuration file given. Using defaults..."
fi

# Installing prerequisites is to be done first.
if [ "$INSTALL_PREREQUISITES" != "true" ]
then
  . $BUILD_SCRIPTS_DIR/install-prerequisites.sh
fi

p "Do we have extra pre-requisites ?" $EXTRA_PREINSTALL_SCRIPT

if [ ! -z "$EXTRA_PREINSTALL_SCRIPT" ]
then
  if [ -x "$APP_SOURCE_DIR/$EXTRA_PREINSTALL_SCRIPT" ]; then
    . $APP_SOURCE_DIR/$EXTRA_PREINSTALL_SCRIPT
  else
    p "Something is wrong with" $APP_SOURCE_DIR/$EXTRA_PREINSTALL_SCRIPT ": permission ?"
    exit 1
  fi
fi

p "Should we install NginX ?" $INSTALL_NGINX

if [ "$INSTALL_NGINX" == "true" ]
then
  . $BUILD_SCRIPTS_DIR/install-nginx.sh
fi

p "Should we install MongoDB ?" $INSTALL_MONGO

if [ "$INSTALL_MONGO" == "true" ]
then
  . $BUILD_SCRIPTS_DIR/install-mongo.sh
fi

p "Should we install Meteor ?" $INSTALL_METEOR

if [ "$INSTALL_METEOR" == "true" ]
then
  p "Creating meteor user..."
  useradd meteor -g www-data -G staff -m -s /bin/bash

  exec su-exec meteor bash $BUILD_SCRIPTS_DIR/install-meteor.sh
fi

p "Do we have extra post steps ?" $EXTRA_POSTINSTALL_SCRIPT

if [ ! -z "$EXTRA_POSTINSTALL_SCRIPT" ]
then
  if [ -x "$APP_SOURCE_DIR/$EXTRA_POSTINSTALL_SCRIPT" ]; then
    . $APP_SOURCE_DIR/$EXTRA_POSTINSTALL_SCRIPT
  else
    p "Something is wrong with" $APP_SOURCE_DIR/$EXTRA_POSTINSTALL_SCRIPT ": permission ?"
    exit 1
  fi
fi
