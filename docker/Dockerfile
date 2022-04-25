FROM rockylinux/rockylinux:8.5 AS downloader

# Install virtio-win package
RUN --mount=type=cache,target=/var/cache/dnf \
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

# Copy from build/extract statge
FROM scratch AS export-stage
COPY --from=downloader /usr/share/virtio-win/virtio-win.iso /virtio-win.iso
COPY --from=downloader /usr/share/virtio-win/VERSION.txt /VERSION.txt
