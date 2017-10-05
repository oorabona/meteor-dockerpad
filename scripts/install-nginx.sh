#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

if [ -f $APP_SOURCE_DIR/launchpad.conf ]; then
  source <(grep INSTALL_NGINX $APP_SOURCE_DIR/launchpad.conf)
  echo "have launchpad.conf ! $INSTALL_NGINX"
fi

if [ "$INSTALL_NGINX" == "true" ]; then
  p "Installing NginX..."
  apt install -y nginx
  envsubst \$APP_BUNDLE_DIR < $BUILD_SCRIPTS_DIR/nginx.conf.tmpl >  /etc/nginx/sites-available/default
  chown -R www-data:www-data /var/log/nginx;
  chmod -R u+X /var/log/nginx;
else
  p "Not installing NginX !"
fi
