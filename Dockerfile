FROM atende/baseimage-jdk

MAINTAINER Giovanni Silva giovanni@atende.info

ENV SOFTWARE_NAME=crowd

ENV SOFTWARE_VERSION=2.8.0

ENV SOFTWARE_PORT=8095

# Disable SSH (Not using it at the moment).
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

COPY install.sh /root/install.sh

RUN chmod +x /root/install.sh

# Install
RUN mkdir /root/scripts
COPY scripts/install_impl.sh /root/scripts/install_impl.sh
RUN chmod +x /root/scripts/install_impl.sh
RUN /root/install.sh

# Run
COPY run.sh /etc/my_init.d/run.sh
COPY scripts/run_impl.sh /root/scripts/run_impl.sh
RUN chmod +x /etc/my_init.d/run.sh

EXPOSE 8095

CMD  ["/sbin/my_init"]
