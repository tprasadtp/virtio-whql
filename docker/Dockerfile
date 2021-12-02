#syntax=docker/dockerfile:1.2

FROM rockylinux/rockylinux:latest AS virtio-downloader

RUN mkdir /build

# renovate: datasource=repology depName=rocky_8/virtio-win versioning=loose
ENV VIRTIO_WIN_VERSION="1.9.19-1.el8"

# Install virtio-win and copy virtio-win.iso and uninstall it
RUN --mount=type=cache,target=/var/cache/yum \
    dnf install -y virtio-win-${VIRTIO_WIN_VERSION} \
    && mkdir /opt/virtio \
    && cp /usr/share/virtio-win/virtio-win.iso /opt/virtio/virtio-win.iso \
    && dnf remove -y virtio-win

RUN echo "$VIRTIO_WIN_VERSION" > /opt/virtio/VERSION.txt

# Copy from build/extract statge
FROM scratch AS export-stage
COPY --from=virtio-downloader /opt/virtio/ /
