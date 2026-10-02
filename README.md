# Docker State Exporter

Exporter for docker container state

Prometheus exporter for docker container state, written in Go.

One of the best known exporters of docker container information is [cAdvisor](https://github.com/google/cadvisor).\
However, cAdvisor does not export the state of the container.

This exporter will only export the container status and the restarts count.

## Installation and Usage

The `docker_state_exporter` listens on HTTP port 8080 by default.

### Docker

For Docker run.

```bash
sudo docker run -d \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  -p 8080:8080 \
  karugaru/docker_state_exporter \
  -listen-address=:8080
```

For Docker compose.

```yaml
---
version: '3.8'

services:
  docker_state_exporter:
    image: karugaru/docker_state_exporter
    volumes:
      - type: bind
        source: /var/run/docker.sock
        target: /var/run/docker.sock
    ports:
      - "8080:8080"
```

## Metrics

This exporter will export the following metrics.

- container_state_health_status
- container_state_status
- container_state_oomkilled
- container_state_startedat
- container_state_finishedat
- container_restartcount

These metrics will be the same as the results of docker inspect.

This exporter also exports the standard
[Go Collector](https://pkg.go.dev/github.com/prometheus/client_golang/prometheus#NewGoCollector)
and [Process Collector](https://pkg.go.dev/github.com/prometheus/client_golang/prometheus#NewProcessCollector).

## Caution

This exporter will do a docker inspect every time prometheus pulls.\
If a large number of requests are made, there will be performance issues. (I think. Not verified.)\
So, this app caches the result of docker inspect for 1 second.
So, please note that if you set the scrape_interval of prometheus to less than one second, you may get the same result back.

## Development building and running

The image `dometec/dockerstateexporter` is published for linux/amd64 and linux/arm64 (e.g. AWS Graviton).
Dependencies are pinned in `go.mod`/`go.sum`.

### Build

Local image for the current platform:

```bash
docker build -t dockerstateexporter:test .
```

Multi-architecture image pushed to Docker Hub (needs `docker buildx` with a `docker-container` builder;
Go cross-compiles, no QEMU emulation needed):

```bash
docker buildx create --name multiarch --driver docker-container --use   # once
docker buildx build --platform linux/amd64,linux/arm64 -t dometec/dockerstateexporter:<version> --push .
```

### Run

```bash
sudo docker run -d \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  -p 8080:8080 \
  docker_state_exporter_test \
  -listen-address=:8080
```

$ /usr/local/bin/aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 050268365445.dkr.ecr.eu-west-1.amazonaws.com/ngvcloud
$ docker build . -t 050268365445.dkr.ecr.eu-west-1.amazonaws.com/ngvcloud/dockerstateexporter:1.0.0
$ docker push 050268365445.dkr.ecr.eu-west-1.amazonaws.com/ngvcloud/dockerstateexporter:1.0.0