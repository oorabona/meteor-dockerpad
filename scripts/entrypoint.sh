#!/bin/bash
set -e
source $BUILD_SCRIPTS_DIR/common.sh

start() {
  if [ -f $APP_BUNDLE_DIR/settings.json ]
  then
    export METEOR_SETTINGS=$(cat $APP_BUNDLE_DIR/settings.json)
  fi

  # try to start local MongoDB if no external MONGO_URL was set
  if [[ "${MONGO_URL}" == *"127.0.0.1"* ]]; then
    if hash mongod 2>/dev/null; then
      p "External MONGO_URL not found. Starting local MongoDB..."
      exec su-exec mongodb mongod --storageEngine=wiredTiger > /dev/null 2>&1 &
    else
      p "ERROR: Mongo not installed inside the container."
      p "Rebuild with INSTALL_MONGO=true in your launchpad.conf or supply a MONGO_URL environment variable."
      exit 1
    fi
  fi

  # If NginX was installed, start it ...
  nx=$(command -v nginx)

  if [ -f "$nx" ]; then
    p "Starting NginX..."
    "$nx" "-g" "daemon on;"
  fi

  # Set a delay to wait to start the Node process
  if [[ $STARTUP_DELAY ]]; then
    echo "Delaying startup for $STARTUP_DELAY seconds..."
    sleep $STARTUP_DELAY
  fi

  # Start app
  p "=> Starting app on port $PORT..."

  # allow the container to be started with `--user`
  if [ "$(id -u)" = "0" ]; then
    cd $APP_BUNDLE_DIR/bundle
    exec su-exec meteor meteor node $APP_MAINJS
  fi
}

if [ "${1:0:1}" = '-' ]; then
  set -- node "$@"
fi

if [ "$1" = "start" ]; then
  start
else
  exec "$@"
fi
