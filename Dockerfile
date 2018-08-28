FROM node:8-stretch

EXPOSE 8080 4443

RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list && \
    apt update && \
    apt dist-upgrade -y && \
    apt install -y \
        build-essential \
        certbot \
        cron \
        git \
        libcap2-bin \
        libffi-dev \
        libnanomsg-dev \
        libnanomsg4 \
        libopenzwave1.5 \
        libopenzwave1.5-dev \
        python \
        python-pip \
        python-setuptools \
        python3 \
        python3-pip \
        python3-setuptools \
        runit \
        sudo && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip2 install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip3 install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip3 install git+https://github.com/mycroftai/adapt#egg=adapt-parser && \
    usermod -a -G sudo node && \
    touch /etc/inittab && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ARG gateway_url
ENV gateway_url ${url:-https://github.com/mozilla-iot/gateway}
ARG gateway_branch
ENV gateway_branch ${branch:-master}

USER node
WORKDIR /home/node
RUN set -x && \
    npm install yarn && \
    mkdir mozilla-iot && \
    cd mozilla-iot && \
    git clone --depth 1 --recursive https://github.com/mozilla-iot/intent-parser && \
    git clone --depth 1 --recursive -b ${gateway_branch} ${gateway_url} && \
    cd gateway && \
    /home/node/node_modules/.bin/yarn --verbose

USER root
ADD service /etc/service
ADD cron.d /etc/cron.d
ADD scripts /opt/scripts

ENTRYPOINT ["/usr/bin/runsvdir", "/etc/service"]
