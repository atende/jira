#!/bin/bash
post_install(){
  echo "crowd.home=/opt/crowd-home" > /opt/crowd/crowd-webapp/WEB-INF/classes/crowd-init.properties
}
