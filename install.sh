#!/bin/bash

install(){
  echo "Downloading software ${SOFTWARE_NAME}"
  curl -LSs https://www.atlassian.com/software/${SOFTWARE_NAME}/downloads/binary/atlassian-${SOFTWARE_NAME}-${SOFTWARE_VERSION}.tar.gz -o /tmp/${SOFTWARE_NAME}.tar.gz
  echo "Installing ${SOFTWARE_NAME}"
  mkdir -p /opt/${SOFTWARE_NAME}
  tar zxf /tmp/${SOFTWARE_NAME}.tar.gz --strip=1 -C /opt/${SOFTWARE_NAME}
  rm /tmp/${SOFTWARE_NAME}.tar.gz

  useradd --create-home --home-dir /opt/${SOFTWARE_NAME}-home --shell /bin/bash ${SOFTWARE_NAME}

  chown -R ${SOFTWARE_NAME}.${SOFTWARE_NAME} /opt/${SOFTWARE_NAME}

  mkdir -p /opt/${SOFTWARE_NAME}-home
}
post_install(){
  echo "${SOFTWARE_NAME}.home=/opt/${SOFTWARE_NAME}-home" > /opt/${SOFTWARE_NAME}/atlassian-${SOFTWARE_NAME}/WEB-INF/classes/${SOFTWARE_NAME}-application.properties
}

source /root/scripts/install_impl.sh

install
post_install
