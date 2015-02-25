FROM giovannicandido/baseimage-jdk

MAINTAINER Giovanni Silva giovanni@atende.info

ENV SOFTWARE_NAME=crowd

ENV SOFTWARE_VERSION=2.8.0

COPY install.sh /root/install.sh

RUN chmod +x /root/install.sh

RUN /root/install.sh

COPY run.sh /etc/my_init.d/run.sh
RUN mkdir /root/scripts
COPY scripts/install_impl.sh /root/scripts/install_impl.sh

EXPOSE 8095

CMD  ["/sbin/my_init"]
