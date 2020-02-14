FROM node:8-buster

EXPOSE 8080 4443

ARG gateway_addon_version
ENV gateway_addon_version ${gateway_addon_version:-@v0.11.0}

RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list && \
    apt update && \
    apt dist-upgrade -y && \
    apt install -y \
        arping \
        build-essential \
        ffmpeg \
        git \
        libcap2-bin \
        libffi-dev \
        libnanomsg-dev \
        libnanomsg5 \
        libnss-mdns \
        libudev-dev \
        libusb-1.0-0-dev \
        lsb-release \
        mosquitto \
        net-tools \
        pkg-config \
        python \
        python-pip \
        python-setuptools \
        python3 \
        python3-pip \
        python3-setuptools \
        runit \
        sudo \
        udev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip3 install git+https://github.com/mozilla-iot/gateway-addon-python${gateway_addon_version}#egg=gateway_addon && \
    pip3 install git+https://github.com/mycroftai/adapt#egg=adapt-parser && \
    usermod -a -G sudo,dialout node && \
    touch /etc/inittab && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ARG gateway_url
ENV gateway_url ${gateway_url:-https://github.com/mozilla-iot/gateway}
ARG gateway_branch
ENV gateway_branch ${gateway_branch:-master}

USER node
WORKDIR /home/node
RUN set -x && \
    mkdir mozilla-iot && \
    cd mozilla-iot && \
    git clone --depth 1 --recursive https://github.com/mozilla-iot/intent-parser && \
    git clone --depth 1 --recursive -b ${gateway_branch} ${gateway_url} && \
    cd gateway && \
    npm install && \
    ./node_modules/.bin/webpack && \
    npm prune --production

USER root
ADD avahi-daemon.conf /etc/avahi
ADD service /etc/service
ADD init.sh /
RUN cp /home/node/mozilla-iot/gateway/tools/udevadm /bin/udevadm

ENTRYPOINT ["/init.sh"]
