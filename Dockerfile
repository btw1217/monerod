# docker run -p 18080-18081:18080-18081 -v /mnt/x/monero/:/srv/monero -d --restart always btw1217/monerod

# centos base image
FROM centos:7

# set env for monerod download
ENV MONERO_VERSION=0.17.3.0

# copy repo file for tor repo
COPY tor.repo /etc/yum.repos.d/tor.repo

# download and install tor and monerod
RUN yum update -y \
    && yum install bzip2 epel-release -y \
    && useradd --system monero \
    && mkdir -p /opt/monero \
    && mkdir -p /srv/monero \
    && chown -R monero:monero /srv/monero \
    && mkdir - p /var/log/monero \
    && chown -R monero:monero /var/log/monero \
    && curl -Lo monero.tar.bz2 https://downloads.getmonero.org/linux64 \
    && tar -xf monero.tar.bz2 \
    && mv monero-x86_64-linux-gnu-v*/* /opt/monero \
    && chown -R monero:monero /opt/monero \
    && yes | yum install tor -y

# copy config files and startup script
COPY --chown=toranon:toranon ./torrc /etc/tor/torrc
COPY --chown=toranon:toranon ./monero /var/lib/tor/monero
COPY monero.conf /etc/monero.conf
COPY start.sh start.sh

# set permissions for monero folder
RUN chmod 700 /var/lib/tor/monero

# run startup script
ENTRYPOINT ./start.sh

# ports used by monerod
EXPOSE 18080 18081