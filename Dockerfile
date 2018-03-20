ARG   NODE_CODENAME=latest
FROM  node:${NODE_CODENAME}
MAINTAINER Olivier Orabona <olivier.orabona@gmail.com>

# Global environment for everything following
ENV DEBIAN_FRONTEND noninteractive

# Default values for Meteor environment variables
ENV ROOT_URL=http://localhost \
    MONGO_URL=mongodb://127.0.0.1:27017/meteor \
    MAIL_URL=smtp://xxx:yyy@zzz.tld \
    PORT=3000 \
    METEOR_SETTINGS_FILE=settings.json \
    MONGO_OPLOG_URL=mongodb://mongodb/local \
    APP_MAINJS=main.js

# Expose both but only one should be used after deployment
EXPOSE 3000/tcp 80/tcp

# build directories
ENV APP_SOURCE_DIR=/opt/meteor/src \
    APP_BUNDLE_DIR=/opt/meteor/dist \
    BUILD_SCRIPTS_DIR=/opt/build_scripts

# Add entrypoint and other build scripts and (optional) conf files
COPY scripts conf $BUILD_SCRIPTS_DIR/

RUN chmod -R 750 $BUILD_SCRIPTS_DIR
RUN $BUILD_SCRIPTS_DIR/install-prerequisites.sh

# Below will happen at app build time...
# Node flags for the Meteor build tool
ONBUILD ENV TOOL_NODE_FLAGS=$TOOL_NODE_FLAGS \
            INSTALL_MONGO=$INSTALL_MONGO \
            INSTALL_NGINX=$INSTALL_NGINX \
            EXTRA_INSTALL_SCRIPT=$EXTRA_INSTALL_SCRIPT

# optionally custom apt dependencies
ONBUILD RUN if [ "$EXTRA_INSTALL_SCRIPT" ]; then exec "$EXTRA_INSTALL_SCRIPT"; fi

# copy the app to the container
ONBUILD COPY . $APP_SOURCE_DIR

# install all dependencies, build app, clean up
ONBUILD RUN   $BUILD_SCRIPTS_DIR/install-mongo.sh && \
  $BUILD_SCRIPTS_DIR/install-nginx.sh && \
  $BUILD_SCRIPTS_DIR/install-meteor.sh && \
  $BUILD_SCRIPTS_DIR/build-project.sh && \
  $BUILD_SCRIPTS_DIR/post-build-cleanup.sh

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["start"]
