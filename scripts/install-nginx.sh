#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

p "Installing NginX..."
apt install -y nginx
envsubst \$APP_BUNDLE_DIR < $BUILD_SCRIPTS_DIR/nginx.conf.tmpl >  /etc/nginx/sites-available/default
chown -R www-data:www-data /var/log/nginx;
chmod -R u+X /var/log/nginx;
