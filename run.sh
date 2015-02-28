#!/bin/bash

PROXY_PORT=${PROXY_PORT:-80}
PROXY_SCHEME=${PROXY_SCHEME:-http}
PROXY_SECURED=${PROXY_SECURED:-false}
TOMCAT_LOCATION=/opt/${SOFTWARE_NAME}

pre_start_action() {
  if [ ! -z "$VIRTUAL_HOST" ]; then
    if [ ! -e "${TOMCAT_LOCATION}/conf/server.xml.replaced" ]; then
      cp ${TOMCAT_LOCATION}/conf/server.xml ${TOMCAT_LOCATION}/conf/server.xml.original
    fi
    cat ${TOMCAT_LOCATION}/conf/server.xml.original | sed -e "s/<Connector port=\"${SOFTWARE_PORT}\"/<Connector port=\"${SOFTWARE_PORT}\"\n\nproxyName=\"${VIRTUAL_HOST}\"\nproxyPort=\"${PROXY_PORT}\"\nscheme=\"${PROXY_SCHEME}\"\nsecured=\"${PROXY_SECURED}\"\n/g" > ${TOMCAT_LOCATION}/conf/server.xml.proxed
    cp ${TOMCAT_LOCATION}/conf/server.xml.proxed ${TOMCAT_LOCATION}/conf/server.xml
    touch ${TOMCAT_LOCATION}/conf/server.xml.replaced
  else
    if [ -e "${TOMCAT_LOCATION}/conf/server.xml.original" ]; then
      mv ${TOMCAT_LOCATION}/conf/server.xml.original ${TOMCAT_LOCATION}/conf/server.xml
      rm ${TOMCAT_LOCATION}/conf/server.xml.replaced
    fi
  fi
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
