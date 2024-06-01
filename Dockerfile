# renovate: datasource=github-releases depName=JonasProgrammer/docker-machine-driver-hetzner
ARG DOCKER_MACHINE_DRIVER_HETZNER_VERSION=5.0.2

FROM alpine/git:2.45.1@sha256:4d7fe8d770483993c0cec264d49a573bac49e5239db47a9846572352e72da49c AS builder-git

ARG BUILD_USER_UID=76543
ARG BUILD_USER_GID=76543 

ARG DOCKER_MACHINE_DRIVER_HETZNER_VERSION

RUN mkdir /build && chown ${BUILD_USER_UID}:${BUILD_USER_GID} /build

USER ${BUILD_USER_UID}:${BUILD_USER_GID}
WORKDIR /build

RUN git clone https://github.com/JonasProgrammer/docker-machine-driver-hetzner . && git checkout "${DOCKER_MACHINE_DRIVER_HETZNER_VERSION}" && rm -rf .git


FROM golang:1.22.3-alpine@sha256:7e788330fa9ae95c68784153b7fd5d5076c79af47651e992a3cdeceeb5dd1df0 AS builder-go

ARG BUILD_USER_UID=76543
ARG BUILD_USER_GID=76543 

RUN mkdir /build && chown ${BUILD_USER_UID}:${BUILD_USER_GID} /build

COPY --from=builder-git --chown=${BUILD_USER_UID}:${BUILD_USER_GID} /build/ /build/

USER ${BUILD_USER_UID}:${BUILD_USER_GID}
WORKDIR /build

RUN GOCACHE=/build/.gocache CGO_ENABLED=0 GOOS=linux go build -o docker-machine-driver-hetzner


FROM gitlab/gitlab-runner:alpine-v17.0.0@sha256:1979e0d80f503489de2893877fff6d242931f1fffc779964a9c300e2ca2d497c

COPY --from=builder-go --chown=0:0 /build/docker-machine-driver-hetzner /usr/bin/
