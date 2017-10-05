#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

p "Performing final cleanup..."

# get out of the src dir, so we can delete it
cd $APP_BUNDLE_DIR

# Clean out docs
rm -rf /usr/share/{doc,doc-base,man,locale,zoneinfo}

# Clean out package management dirs
rm -rf /var/lib/{cache,log}

# remove app source
rm -rf $APP_SOURCE_DIR

# remove meteor
rm -rf /usr/local/bin/meteor
rm -rf /root/.meteor

# clean additional files created outside the source tree
rm -rf /root/{.npm,.cache,.config,.cordova,.local}
rm -rf /tmp/*

# remove npm
npm cache clean --force

# make sure we keep only production code
npm prune --production

# remove os dependencies
apt-get purge -y --auto-remove bzip2 ca-certificates curl git python
apt-get -y autoremove
apt-get -y clean
apt-get -y autoclean
rm -rf /var/lib/apt/lists/*
