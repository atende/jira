install(){
  echo "Downloading"
  curl -LS https://www.atlassian.com/software/${SOFTWARE_NAME}/downloads/binary/atlassian-crowd-${SOFTWARE_VERSION}.tar.gz -o /tmp/${SOFTWARE_NAME}.tar.gz
  mkdir -p /opt/${SOFTWARE_NAME}
  tar zxf /tmp/${SOFTWARE_NAME}.tar.gz --strip=1 -C /opt/${SOFTWARE_NAME}

  useradd --create-home --home-dir /opt/${SOFTWARE_NAME} --shell /bin/bash ${SOFTWARE_NAME}

  mkdir -p /opt/${SOFTWARE_NAME}-home
}
post_install(){ # Default NO Op implementation
  echo "post_install"
}
cd /root
source /root/scripts/install_impl.sh

install
post_install
