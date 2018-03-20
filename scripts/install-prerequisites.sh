#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

p "Updating packages cache..."
apt update

p "Installing needed base packages..."
apt install -y gettext-base git ca-certificates make gcc curl

p "Apply safe upgrade to our base image..."
apt upgrade -y

p "Installing prerequisites su-exec..."

cd /tmp
git clone https://github.com/ncopa/su-exec.git
cd su-exec
make
chmod +x su-exec
cp su-exec /usr/local/bin/
