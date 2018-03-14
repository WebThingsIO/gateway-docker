# Docker Mozilla IoT Gateway

Docker image based on Debian Stretch for running the [Mozilla IoT Gateway](https://github.com/mozilla-iot/gateway).

# Building

```
docker build -t gateway .
```

# Running

```
docker run \
    -d \
    -p 80:8080 \
    -p 443:4443 \
    --name mozilla-iot-gateway \
    gateway
```
