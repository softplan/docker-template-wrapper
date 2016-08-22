#!/bin/sh

USER_ID=${LOCAL_UID:-9001}

echo "Starting with UID : $USER_ID"
## adduser differs from default GNU conterpart
adduser -D -s /bin/bash -u $USER_ID -g "" wrapperuser

su-exec wrapperuser ${DOCKER_TEMPLATE_WRAPPER_HOME}/update-dockerfile  "$@"
