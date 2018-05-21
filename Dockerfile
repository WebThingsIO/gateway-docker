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
    npm install -g yarn && \
    usermod -a -G sudo node && \
    touch /etc/inittab && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER node
RUN cd /home/node && \
    mkdir mozilla-iot && \
    cd mozilla-iot && \
    git clone https://github.com/mozilla-iot/intent-parser && \
    git clone https://github.com/mozilla-iot/gateway && \
    cd gateway && \
    yarn

USER root
ADD service /etc/service
ADD cron.d /etc/cron.d
ADD scripts /opt/scripts

ENTRYPOINT ["/usr/bin/runsvdir", "/etc/service"]
