#!/bin/bash

PROXY_PORT=${PROXY_PORT:-80}
PROXY_SCHEME=${PROXY_SCHEME:-http}
PROXY_SECURED=${PROXY_SECURED:-false}

pre_start_action() {
  if [ ! -z "$VIRTUAL_HOST" ]; then
    if [ ! -e "/opt/${SOFTWARE_NAME}/conf/server.xml.replaced" ]; then
      cp /opt/${SOFTWARE_NAME}/conf/server.xml /opt/${SOFTWARE_NAME}/conf/server.xml.original
    fi
    cat /opt/${SOFTWARE_NAME}/conf/server.xml.original | sed -e "s/<Connector port=\"${SOFTWARE_PORT}\"/<Connector port=\"${SOFTWARE_PORT}\"\n\nproxyName=\"${VIRTUAL_HOST}\"\nproxyPort=\"${PROXY_PORT}\"\nscheme=\"${PROXY_SCHEME}\"\nsecured=\"${PROXY_SECURED}\"\n/g" > /opt/confluence/conf/server.xml.proxed
    cp /opt/${SOFTWARE_NAME}/conf/server.xml.proxed /opt/${SOFTWARE_NAME}/conf/server.xml
    touch /opt/${SOFTWARE_NAME}/conf/server.xml.replaced
  else
    if [ -e "/opt/${SOFTWARE_NAME}/conf/server.xml.original" ]; then
      mv /opt/${SOFTWARE_NAME}/conf/server.xml.original /opt/${SOFTWARE_NAME}/conf/server.xml
      rm /opt/${SOFTWARE_NAME}/conf/server.xml.replaced
    fi
  fi
}
start() {
  # Ensure the the volume home has the correct permissions, because this can cause errors
  chown ${SOFTWARE_NAME}.${SOFTWARE_NAME} -R /opt/${SOFTWARE_NAME}-home
  /bin/su - ${SOFTWARE_NAME} -c "/opt/${SOFTWARE_NAME}/bin/start-${SOFTWARE_NAME}.sh"
}
post_start(){
  : # No Op
}

source /root/scripts/run_impl.sh

pre_start_action
start
post_start
