# Docker Mozilla IoT Gateway

Docker image based on Debian Stretch for running the [Mozilla IoT Gateway](https://github.com/mozilla-iot/gateway).

# Building

```
$ docker build -t gateway .
```

# Running

```
$ docker run \
    -d \
    -v /path/to/shared/data:/home/user/.mozilla-iot \
    --net=host \
    --name mozilla-iot-gateway \
    gateway
```
