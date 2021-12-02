#!/bin/bash

set -euo pipefail

if [[ ! -f docker/build/VERSION.txt ]]; then
    echo "Error! VERSION.txt file not found!"
    exit 1
fi

CURRENT_VERSION=$(cat docker/build/VERSION.txt | tr -dc '[:print:]')

if [[ -z $CURRENT_VERSION ]]; then
    echo "Error! VERSION.txt file is empty!"
    exit 1
fi

LATEST_RELEASE="$(gh api repos/:owner/:repo/releases/latest --jq '.tag_name')"

if [[ -z $LATEST_RELEASE ]]; then
    echo "Error! Failed to get latest tag from GitHub!"
    exit 1
fi

if [[ $CURRENT_VERSION == "$LATEST_RELEASE" ]]; then
    echo "All Good! No need to create a new release"
    echo "Latest release version is same as extracted!"
else
    echo "Current Version: $CURRENT_VERSION"
    echo "Latest Release: $LATEST_RELEASE"

    echo "Create: Tag"
    git tag "$CURRENT_VERSION"

    echo "Create: Changelog"
    make changelog

    echo "Create: Checksums"
    sha256sum docker/build/virtio-win.iso | cut -f1 -d ' ' > docker/build/virtio-win.iso.sha256
    sha256sum docker/build/virtio-win-gt-x64.msi | cut -f1 -d ' ' > docker/build/virtio-win-gt-x64.msi.sha256
    sha256sum docker/build/virtio-win-guest-tools.exe | cut -f1 -d ' ' > docker/build/virtio-win-guest-tools.exe.sha256

    echo "Create: GH-Release"
    gh release create \
        --notes-file docs/changelog.md \
        --title "$CURRENT_VERSION" \
        "$CURRENT_VERSION" \
        docker/build/virtio-win.iso \
        docker/build/virtio-win.iso.sha256 \
        docker/build/virtio-win-gt-x64.msi \
        docker/build/virtio-win-gt-x64.msi.sha256 \
        docker/build/virtio-win-guest-tools.exe \
        docker/build/virtio-win-guest-tools.exe.sha256
fi
