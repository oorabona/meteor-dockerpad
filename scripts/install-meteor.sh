#!/bin/bash
#
# Doing the steps necessary to install Meteor properly
#

set -e
source $BUILD_SCRIPTS_DIR/common.sh

p "Retrieving Meteor installation script..."

# download installer script
curl https://install.meteor.com -o /tmp/install_meteor.sh

# If we want a specific version of Meteor, we patch installation script to
# download it. Otherwise we automagically detect it from project source code
# and use it instead.
if [ -f $APP_SOURCE_DIR/launchpad.conf ]; then
  source <(grep METEOR_VERSION $APP_SOURCE_DIR/launchpad.conf)
fi

if [ "$METEOR_VERSION" == "" ]
then
  # read in the release version in the app
  METEOR_VERSION=$(head $APP_SOURCE_DIR/.meteor/release | cut -d "@" -f 2)
fi

if [ "$METEOR_VERSION" != "latest" ]
then
  # set the release version in the install script
  sed -i.bak "s/RELEASE=.*/RELEASE=\"$METEOR_VERSION\"/g" /tmp/install_meteor.sh
fi

# replace tar command with bsdtar in the install script (bsdtar -xf "$TARBALL_FILE" -C "$INSTALL_TMPDIR")
# https://github.com/jshimko/meteor-launchpad/issues/39
# sed -i.bak "s/tar -xzf.*/bsdtar -xf \"\$TARBALL_FILE\" -C \"\$INSTALL_TMPDIR\"/g" /tmp/install_meteor.sh

# install
p "Installing Meteor $METEOR_VERSION..."
sh /tmp/install_meteor.sh
