FROM node:12-buster-slim

EXPOSE 8080 4443

ARG gateway_url
ENV gateway_url ${gateway_url:-https://github.com/mozilla-iot/gateway}
ARG gateway_branch
ENV gateway_branch ${gateway_branch:-master}
ARG gateway_addon_version
ENV gateway_addon_version ${gateway_addon_version:-master}

ARG DEBIAN_FRONTEND=noninteractive
RUN set -x && \
    echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
    apt update && \
    apt dist-upgrade -y && \
    apt install -y \
        arping \
        autoconf \
        build-essential \
        ffmpeg \
        git \
        iputils-ping \
        libcap2-bin \
        libffi-dev \
        libnss-mdns \
        libpng-dev \
        libtool \
        lsb-release \
        mosquitto \
        net-tools \
        pkg-config \
        python \
        python3 \
        python3-pip \
        python3-setuptools \
        sudo \
        zlib1g-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 install git+https://github.com/mozilla-iot/gateway-addon-python@${gateway_addon_version}#egg=gateway_addon && \
    usermod -a -G sudo,dialout node && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER node
WORKDIR /home/node
RUN set -x && \
    mkdir mozilla-iot && \
    cd mozilla-iot && \
    git clone --depth 1 --recursive https://github.com/mozilla-iot/intent-parser && \
    git clone --depth 1 --recursive -b ${gateway_branch} ${gateway_url} && \
    cd gateway && \
    CPPFLAGS="-DPNG_ARM_NEON_OPT=0" npm ci && \
    ./node_modules/.bin/webpack && \
    rm -rf ./node_modules/gifsicle && \
    rm -rf ./node_modules/mozjpeg && \
    npm prune --production && \
    sed -i \
        -e 's/ cli: true/ cli: false/' \
        -e 's/ behindForwarding: true/ behindForwarding: false/' \
        -e 's/ localAccess: true/ localAccess: false/' \
        config/default.js

USER root
ADD avahi-daemon.conf /etc/avahi
ADD init.sh /
RUN cp /home/node/mozilla-iot/gateway/tools/udevadm /bin/udevadm

ENTRYPOINT ["/init.sh"]
