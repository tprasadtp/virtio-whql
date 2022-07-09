#!/bin/bash
set -eo pipefail
echo "-> Building VirtIO ISO via Docker"
mkdir -p docker/build
DOCKER_BUILDKIT=1 docker \
    build \
    --tag ghcr.io/tprasadtp/dev-virtio-whql \
    --output type=local,dest=docker/build \
    docker
