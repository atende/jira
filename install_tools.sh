#!/bin/bash
# Install necessary tools for the scripts and functionality of application

# Scala Language
curl -LSs http://downloads.typesafe.com/scala/2.11.6/scala-2.11.6.tgz -o /tmp/scala.tgz
mkdir /usr/local/scala
tar zxf /tmp/scala.tgz --strip-components=1 -C /usr/local/scala
ln -s /usr/local/scala/bin/scala /usr/local/bin/scala
ln -s /usr/local/scala/bin/scalac /usr/local/bin/scalac
ln -s /usr/local/scala/bin/scalap /usr/local/bin/scalap
ln -s /usr/local/scala/bin/scaladoc /usr/local/bin/scaladoc
