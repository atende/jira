#!/bin/bash

PROXY_PORT=${PROXY_PORT:-80}
PROXY_SCHEME=${PROXY_SCHEME:-http}
PROXY_SECURED=${PROXY_SECURED:-false}
TOMCAT_LOCATION=/opt/${SOFTWARE_NAME}


pre_start_action() {
  exec /usr/local/bin/scala /root/scripts/configuration.scala
}
start() {
  # Ensure the volume home has the correct permissions, because this can cause errors
  chown ${SOFTWARE_NAME}.${SOFTWARE_NAME} -R /opt/${SOFTWARE_NAME}-home
  exec /sbin/setuser ${SOFTWARE_NAME} /opt/${SOFTWARE_NAME}/bin/start-${SOFTWARE_NAME}.sh
}
post_start(){
  : # No Op
}

source /root/scripts/run_impl.sh

pre_start_action
start
post_start
