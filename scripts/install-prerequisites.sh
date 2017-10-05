#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

p "Installing prerequisites su-exec..."

cd /tmp
git clone https://github.com/ncopa/su-exec.git
cd su-exec
make
chmod +x su-exec
cp su-exec /usr/local/bin/

p "Updating packages cache..."
apt update

p "Installing needed base packages..."
apt install -y apt-utils gettext-base

p "Apply safe upgrade to our base image..."
apt upgrade -y
