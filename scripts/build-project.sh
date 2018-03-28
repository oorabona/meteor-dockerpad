#!/bin/bash
#
# builds a production meteor bundle directory
#
set -e
source $BUILD_SCRIPTS_DIR/common.sh

# We need to chown first to avoid permissions issues
cd $APP_SOURCE_DIR
chown -R meteor. .

# Install app deps
if [ -f package.json ]
then
  p "Found customized package.json: running npm install in app directory..."
  su-exec meteor meteor npm install --production
fi

METEOR_SETTINGS_FILE=${METEOR_SETTINGS_FILE:-settings.json}

if [ -f $METEOR_SETTINGS_FILE ]
then
  p "Found" $METEOR_SETTINGS_FILE "file. Putting it some safe place for later..."
  cp $METEOR_SETTINGS_FILE $APP_BUNDLE_DIR
fi

# build the bundle
p "Building Meteor application..."
su-exec meteor meteor build --directory $APP_BUNDLE_DIR --headless

# run npm install in bundle
p "Running npm install in the server bundle..."
cd $APP_BUNDLE_DIR/bundle/programs/server/
su-exec meteor meteor npm install --production
