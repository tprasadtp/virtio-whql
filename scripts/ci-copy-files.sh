#!/bin/bash
set -eo pipefail

echo "--> Copy Files"

declare ISO_ROOT="$1"

if [[ -z "${ISO_ROOT}" ]] || [[ ! -d "${ISO_ROOT}" ]]; then
    echo "Error! ISO_ROOT(${ISO_ROOT:-NA}) is not a directory or is empty!"
    exit 1
fi

if ! mountpoint -q "${ISO_ROOT}"; then
    echo "Error! ISO_ROOT(${ISO_ROOT:-NA}) is not a mountpoint!"
    exit 1
fi

echo "-> Creating Directories"
mkdir -p docker/build

WINPE_BASE="docker/build/winpe"
WINPE_DRIVER_BASE="docker/build/winpe/\$WinPEDriver\$"
mkdir -p docker/build/winpe

echo "-> Copying Installer"
cp --force "${ISO_ROOT}"/virtio-win-guest-tools.exe \
    docker/build/virtio-win-guest-tools.exe

cp --force "${ISO_ROOT}"/virtio-win-guest-tools.exe \
    "${WINPE_BASE}"/virtio-win-guest-tools.exe

echo "-> Copying License file"
cp --force "${ISO_ROOT}"/virtio-win_license.txt \
    "${WINPE_BASE}"/virtio-win-license.txt

echo "-> Copying Network Drivers"
mkdir -p "${WINPE_DRIVER_BASE}"/NetKVM
cp --force "${ISO_ROOT}/NetKVM/w10/amd64/netkvm.sys" \
    "${WINPE_DRIVER_BASE}"/NetKVM/netkvm.sys
cp --force "${ISO_ROOT}/NetKVM/w10/amd64/netkvm.inf" \
    "${WINPE_DRIVER_BASE}"/NetKVM/netkvm.inf
cp --force "${ISO_ROOT}/NetKVM/w10/amd64/netkvm.cat" \
    "${WINPE_DRIVER_BASE}"/NetKVM/netkvm.cat

cp --force "${ISO_ROOT}/NetKVM/w10/amd64/netkvmco.dll" \
    "${WINPE_DRIVER_BASE}"/NetKVM/netkvmco.dll

echo "-> Copying Disk(viostor) Drivers"
mkdir -p "${WINPE_DRIVER_BASE}"/viostor
cp --force "${ISO_ROOT}/viostor/w10/amd64/viostor.sys" \
    "${WINPE_DRIVER_BASE}"/viostor/viostor.sys
cp --force "${ISO_ROOT}/viostor/w10/amd64/viostor.inf" \
    "${WINPE_DRIVER_BASE}"/viostor/viostor.inf
cp --force "${ISO_ROOT}/viostor/w10/amd64/viostor.cat" \
    "${WINPE_DRIVER_BASE}"/viostor/viostor.cat

echo "-> Copying Entropy(viorng) Drivers"
mkdir -p "${WINPE_DRIVER_BASE}"/viorng
cp --force "${ISO_ROOT}/viorng/w10/amd64/viorng.sys" \
    "${WINPE_DRIVER_BASE}"/viorng/viorng.sys
cp --force "${ISO_ROOT}/viorng/w10/amd64/viorng.inf" \
    "${WINPE_DRIVER_BASE}"/viorng/viorng.inf
cp --force "${ISO_ROOT}/viorng/w10/amd64/viorng.cat" \
    "${WINPE_DRIVER_BASE}"/viorng/viorng.cat

cp --force "${ISO_ROOT}/viorng/w10/amd64/viorngci.dll" \
    "${WINPE_DRIVER_BASE}"/viorng/viorngci.dll
cp --force "${ISO_ROOT}/viorng/w10/amd64/viorngum.dll" \
    "${WINPE_DRIVER_BASE}"/viorng/viorngum.dll

echo "-> Building WinPE ISO"
mkisofs -J -l -R -V \
    "VirtIO-WinPE" \
    -iso-level 4 \
    -o docker/build/virtio-winpe.iso \
    docker/build/winpe

echo "--> Create Checksum (virtio-win.iso)"
sha256sum docker/build/virtio-win.iso | cut -f1 -d ' ' >docker/build/virtio-win.iso.sha256

echo "--> Create Checksum (virtio-winpe.iso)"
sha256sum docker/build/virtio-winpe.iso | cut -f1 -d ' ' >docker/build/virtio-winpe.iso.sha256

echo "--> Create Checksum (virtio-win-guest-tools.exe)"
sha256sum docker/build/virtio-win-guest-tools.exe | cut -f1 -d ' ' >docker/build/virtio-win-guest-tools.exe.sha256
