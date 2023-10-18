# syntax=docker/dockerfile:1.2
ARG DISTRO="registry.access.redhat.com/ubi9/ubi"
ARG TAG="latest"
FROM ${DISTRO}:${TAG} AS downloader

COPY --chown=root:root secrets/consumer /etc/pki/consumer
COPY --chown=root:root secrets/entitlement /etc/pki/entitlement

RUN --mount=type=cache,target=/var/cache/dnf \
    ls -al /etc/pki && \
    dnf install \
        --setopt=keepcache=true \
        --assumeyes \
        --best \
        virtio-win \
    && dnf repoquery \
        --quiet \
        --installed \
        --cacheonly \
        --qf '%{version}-%{release}' \
        virtio-win > /usr/share/virtio-win/VERSION.txt

# # Copy from build/extract statge
FROM scratch AS export-stage
COPY --from=downloader /usr/share/virtio-win/virtio-win.iso virtio-win.iso
COPY --from=downloader /usr/share/virtio-win/VERSION.txt VERSION.txt
