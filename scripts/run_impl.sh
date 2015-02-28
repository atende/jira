#!/bin/bash

PROXY_PORT=${PROXY_PORT:-80}
PROXY_SCHEME=${PROXY_SCHEME:-http}
PROXY_SECURED=${PROXY_SECURED:-false}
TOMCAT_LOCATION=/opt/${SOFTWARE_NAME}/apache-tomcat

start() {
  # Ensure the the volume home has the correct permissions, because this can cause errors
  chown ${SOFTWARE_NAME}.${SOFTWARE_NAME} -R /opt/${SOFTWARE_NAME}-home
  exec /sbin/setuser ${SOFTWARE_NAME} /opt/${SOFTWARE_NAME}/start_${SOFTWARE_NAME}.sh
}
post_start(){
  :
}
