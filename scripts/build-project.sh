#!/bin/bash
#
# builds a production meteor bundle directory
#
set -e
source $BUILD_SCRIPTS_DIR/common.sh

# Fix permissions warning in Meteor >=1.4.2.1 without breaking
# earlier versions of Meteor with --unsafe-perm or --allow-superuser
# https://github.com/meteor/meteor/issues/7959
export METEOR_ALLOW_SUPERUSER=true

cd $APP_SOURCE_DIR

# Install app deps
if [ -f package.json ]
then
  p "Found customized package.json: running npm install in app directory..."
  meteor npm install --production
fi

METEOR_SETTINGS_FILE=${METEOR_SETTINGS_FILE:-settings.json}

if [ -f $METEOR_SETTINGS_FILE ]
then
  p "Found" $METEOR_SETTINGS_FILE "file. Putting it some safe place for later..."
  cp $METEOR_SETTINGS_FILE /etc/settings.json
fi

# build the bundle
p "Building Meteor application..."
mkdir -p $APP_BUNDLE_DIR
meteor build --directory $APP_BUNDLE_DIR --headless

# # run npm install in bundle
p "Running npm install in the server bundle..."
cd $APP_BUNDLE_DIR/bundle/programs/server/
npm install --production

# put the entrypoint script in WORKDIR
mv $BUILD_SCRIPTS_DIR/entrypoint.sh $APP_BUNDLE_DIR/bundle/entrypoint.sh
cp $BUILD_SCRIPTS_DIR/common.sh $APP_BUNDLE_DIR/bundle/common.sh

# change ownership of the app to the node user
chown -R node:www-data $APP_BUNDLE_DIR
