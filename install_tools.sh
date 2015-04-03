#!/bin/bash
# Install necessary tools for the scripts and functionality of application

# Scala Language
curl -LSs http://downloads.typesafe.com/scala/2.11.6/scala-2.11.6.tgz -o /tmp/scala.tgz
tar zxf /tmp/scala.tgz -C /usr/local/
ln -s /usr/local/scala/bin/scala /usr/local/bin/scala
