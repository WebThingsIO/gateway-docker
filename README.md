# Docker Mozilla IoT Gateway

[Docker image](https://github.com/mozilla-iot/gateway-docker) based on Debian Stretch for running the [Mozilla IoT Gateway](https://github.com/mozilla-iot/gateway).

## Compatibility

While the gateway doesn't necessarily require full local network access, some add-ons may. Therefore, it is best to run with the `--net=host` flag. Currently, this flag will not work when using [Docker for Mac](https://docs.docker.com/docker-for-mac/) or [Docker for Windows](https://docs.docker.com/docker-for-windows/) due to [this](https://github.com/docker/for-mac/issues/68) and [this](https://github.com/docker/for-win/issues/543).

## Usage

### AMD64

```shell
docker run \
    -d \
    -v /path/to/shared/data:/home/node/.mozilla-iot \
    --net=host \
    --name mozilla-iot-gateway \
    mozillaiot/gateway:latest
```

### ARM (e.g. Raspberry Pi)

Tested on Raspberry Pi 3 Model B/B+:

```shell
docker run \
    -d \
    -v /path/to/shared/data:/home/node/.mozilla-iot \
    --net=host \
    --name mozilla-iot-gateway \
    mozillaiot/gateway:arm
```

## Parameters

* `-d` - Run in daemon mode (in the background)
* `-v /path/to/shared/data:/home/node/.mozilla-iot` - Change `/path/to/shared/data` to some local path. It will be used to store the "user profile", i.e. add-ons, logs, configuration data, etc.
* `--net=host` - Shares host networking with containeri (**highly recommended**)
* `--name mozilla-iot-gateway` - Name of the container

## Building

If you'd like to build an image yourself, run the following:

```shell
git clone https://github.com/mozilla-iot/gateway-docker
cd gateway-docker
docker build -t gateway .
```
