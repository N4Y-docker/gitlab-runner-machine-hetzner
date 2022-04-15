# renovate: datasource=github-releases depName=JonasProgrammer/docker-machine-driver-hetzner
ARG DOCKER_MACHINE_DRIVER_HETZNER_VERSION=3.7.0

FROM alpine/git:v2.32.0@sha256:a8a31155488a93a4d8abb834777c7b5f9d7c93db6051defbad8cc066b4e90072 AS builder-git

ARG BUILD_USER_UID=76543
ARG BUILD_USER_GID=76543 

ARG DOCKER_MACHINE_DRIVER_HETZNER_VERSION

RUN mkdir /build && chown ${BUILD_USER_UID}:${BUILD_USER_GID} /build

USER ${BUILD_USER_UID}:${BUILD_USER_GID}
WORKDIR /build

RUN git clone https://github.com/JonasProgrammer/docker-machine-driver-hetzner . && git checkout "${DOCKER_MACHINE_DRIVER_HETZNER_VERSION}" && rm -rf .git


FROM golang:1.18.0-alpine@sha256:a2ca4f4c0828b1b426a3153b068bf32a21868911c57a9fc4dccdc5fbb6553b35 AS builder-go

ARG BUILD_USER_UID=76543
ARG BUILD_USER_GID=76543 

RUN mkdir /build && chown ${BUILD_USER_UID}:${BUILD_USER_GID} /build

COPY --from=builder-git --chown=${BUILD_USER_UID}:${BUILD_USER_GID} /build/ /build/

USER ${BUILD_USER_UID}:${BUILD_USER_GID}
WORKDIR /build

RUN GOCACHE=/build/.gocache CGO_ENABLED=0 GOOS=linux go build -o docker-machine-driver-hetzner


FROM gitlab/gitlab-runner:alpine-v14.9.1@sha256:9e9468038ea1d698450641c594b75c226d80cfd052e47bd60adabc3d94c17a16

COPY --from=builder-go --chown=0:0 /build/docker-machine-driver-hetzner /usr/bin/
