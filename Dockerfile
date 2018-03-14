FROM debian:stretch

EXPOSE 8080 4443

RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list && \
    apt update && \
    apt install -y curl gnupg2 && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt update && \
    apt dist-upgrade && \
    apt install -y \
        build-essential \
        certbot \
        cron \
        git \
        libffi-dev \
        libnanomsg-dev \
        libnanomsg4 \
        libopenzwave1.5 \
        libopenzwave1.5-dev \
        nodejs \
        npm \
        python \
        python-pip \
        python-setuptools \
        python3 \
        python3-pip \
        python3-setuptools \
        runit \
        sudo && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip2 install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip3 install git+https://github.com/mozilla-iot/gateway-addon-python#egg=gateway_addon && \
    pip2 install git+https://github.com/mycroftai/adapt#egg=adapt-parser && \
    pip3 install git+https://github.com/mycroftai/adapt#egg=adapt-parser && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash && \
    useradd -m -s /bin/bash -G sudo user && \
    cd /home/user && \
    mkdir mozilla-iot && \
    cd mozilla-iot && \
    git clone https://github.com/mozilla-iot/intent-parser && \
    git clone https://github.com/mozilla-iot/gateway && \
    cd gateway && \
    yarn && \
    chown -R user:user /home/user && \
    touch /etc/inittab && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "0 */12 * * * root /home/user/mozilla-iot/gateway/tools/renew-certificates.sh" > /etc/cron.d/renew-certs

ADD service /etc/service

ENTRYPOINT ["/usr/bin/runsvdir", "/etc/service"]
