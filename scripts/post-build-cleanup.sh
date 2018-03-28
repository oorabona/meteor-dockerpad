#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

p "Performing final cleanup..."

# Clean out docs
rm -rf /usr/share/{doc,doc-base,man,locale,zoneinfo}

# Clean out package management dirs
rm -rf /var/lib/{cache,log}

# remove app source
rm -rf $APP_SOURCE_DIR

# remove npm
su-exec meteor meteor npm cache clean --force

# make sure we keep only production code
su-exec meteor meteor npm prune --production

# remove meteor
# rm -rf /usr/local/bin/meteor
# rm -rf /home/meteor/.meteor

# clean additional files created outside the source tree
rm -rf ~meteor/{.npm,.cache,.config,.cordova,.local}
rm -rf /tmp/*

# remove os dependencies
apt purge -y --auto-remove bzip2 ca-certificates curl git python gcc
apt -y autoremove
apt -y clean
apt -y autoclean
rm -rf /var/lib/apt/lists/*
