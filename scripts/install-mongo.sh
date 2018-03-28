#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

p "Installing MongoDB..."
apt install -y mongodb
