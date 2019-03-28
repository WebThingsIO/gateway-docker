FROM node:8-stretch

EXPOSE 8080 4443

RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list && \
    apt update && \
    apt dist-upgrade -y && \
    apt install -y \
        build-essential \
        ffmpeg \
        git \
        libcap2-bin \
        libffi-dev \
        libnanomsg-dev \
        libnanomsg4 \
        libudev-dev \
        libusb-1.0-0-dev \
        lsb-release \
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
    pip2 install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip3 install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
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
    npm install

USER root
ADD service /etc/service
RUN cp /home/node/mozilla-iot/gateway/tools/udevadm /bin/udevadm

ENTRYPOINT ["/usr/bin/runsvdir", "/etc/service"]
