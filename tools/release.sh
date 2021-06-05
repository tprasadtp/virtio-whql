#!/bin/bash

set -euo pipefail

if [[ ! -e docker/build/VERSION.txt ]]; then
    echo "Error! VERSION.txt not found!"
    exit 1
fi

CURRENT_VERSION=$(cat docker/build/VERSION.txt | tr -dc '[:print:]')

if [[ -z $CURRENT_VERSION ]]; then
    echo "Error! Current VERSION.txt file is empty!"
    exit 1
fi

LATEST_RELEASE="$(gh api repos/:owner/:repo/releases/latest --jq '.tag_name')"

if [[ -z $LATEST_RELEASE ]]; then
    echo "Error! Failed to get current latest tag!"
    exit 1
fi

if [[ $CURRENT_VERSION == "$LATEST_RELEASE" ]]; then
    echo "All Good! Latest reease is same as extracted!"
else
    echo "Current Version: $CURRENT_VERSION"
    echo "Latest Release: $LATEST_RELEASE"

    echo "Create: Tag"
    git tag "$CURRENT_VERSION"

    echo "Create: Changelog"
    make changelog

    echo "Create: GH-Release"
    gh release create \
        --notes-file docs/changelog.md \
        --title "$CURRENT_VERSION" \
        "$CURRENT_VERSION" \
        docker/build/virtio-win.iso
fi
