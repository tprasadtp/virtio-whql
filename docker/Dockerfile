#syntax=docker/dockerfile:1.2

FROM centos:8 AS virtio-base-image

RUN mkdir /build

# renovate: datasource=repology depName=centos_8/virtio-win versioning=loose
ENV VIRTIO_WIN_VERSION="1.9.16-2.el8"
RUN --mount=type=cache,target=/download/cache \
    --mount=type=cache,target=/var/cache/yum \
    --mount=type=tmpfs,target=/download/extract \
    dnf install -y \
    --downloadonly \
    --downloaddir=/download/cache/ \
    virtio-win-"${VIRTIO_WIN_VERSION}" \
    && cd /download/extract \
    && rpm2cpio "/download/cache/virtio-win-${VIRTIO_WIN_VERSION}.noarch.rpm" | cpio -idmv \
    && echo "$VIRTIO_WIN_VERSION" > /build/VERSION.txt \
    && cp /download/extract/usr/share/virtio-win/virtio-win.iso /build/virtio-win.iso

# Copy from build/extract statge
FROM scratch AS export-stage
COPY --from=virtio-base-image /build/ /
