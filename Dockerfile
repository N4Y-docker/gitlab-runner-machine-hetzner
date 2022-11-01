# renovate: datasource=github-releases depName=JonasProgrammer/docker-machine-driver-hetzner
ARG DOCKER_MACHINE_DRIVER_HETZNER_VERSION=3.8.0

FROM alpine/git:v2.36.2@sha256:3ad0f6025feea6c01f552e467989a79a057176c06a9f266de440be406dcf079b AS builder-git

ARG BUILD_USER_UID=76543
ARG BUILD_USER_GID=76543 

ARG DOCKER_MACHINE_DRIVER_HETZNER_VERSION

RUN mkdir /build && chown ${BUILD_USER_UID}:${BUILD_USER_GID} /build

USER ${BUILD_USER_UID}:${BUILD_USER_GID}
WORKDIR /build

RUN git clone https://github.com/JonasProgrammer/docker-machine-driver-hetzner . && git checkout "${DOCKER_MACHINE_DRIVER_HETZNER_VERSION}" && rm -rf .git


FROM golang:1.18.7-alpine@sha256:29c658ca42040ee2e6a0eca20d8ee3580bd284dd2dae33bc8a28517e3bc3f36e AS builder-go

ARG BUILD_USER_UID=76543
ARG BUILD_USER_GID=76543 

RUN mkdir /build && chown ${BUILD_USER_UID}:${BUILD_USER_GID} /build

COPY --from=builder-git --chown=${BUILD_USER_UID}:${BUILD_USER_GID} /build/ /build/

USER ${BUILD_USER_UID}:${BUILD_USER_GID}
WORKDIR /build

RUN GOCACHE=/build/.gocache CGO_ENABLED=0 GOOS=linux go build -o docker-machine-driver-hetzner


FROM gitlab/gitlab-runner:alpine-v15.1.1@sha256:17c0bcdbf45ad9d5b3e8d98f2d9ac11e39b7493d81276711502bf0bf47c57e0a

COPY --from=builder-go --chown=0:0 /build/docker-machine-driver-hetzner /usr/bin/
