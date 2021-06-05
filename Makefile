SHELL := /bin/bash
DOCKER_BUILDKIT  := 1
export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# GitHub
GITHUB_OWNER := tprasadtp
GITHUB_REPO  := virtio-whql

# OCI Metadata
PROJECT_TITLE    := VirtIO WHQL
PROJECT_DESC     := VirtIO WHQL Drivers
PROJECT_URL      := https://tprasadtp.github.io/virtio-whql
PROJECT_SOURCE   := https://github.com/tprasadtp/virtio-whql
PROJECT_LICENSE  := GPLv3

# Include makefiles
include $(REPO_ROOT)/makefiles/help.mk

# Enforce BUILDKIT
ifneq ($(DOCKER_BUILDKIT),1)
$(error ✖ DOCKER_BUILDKIT!=1. Docker Buildkit cannot be disabled on this repo!)
endif

.PHONY: shellcheck
shellcheck: ## Runs shellcheck
	@bash $(REPO_ROOT)/scripts/shellcheck.sh $(shell find $(REPO_ROOT)/root/etc/ -type f -executable)

.PHONY: build
build: clean ## Build ISO
	@mkdir -p $(REPO_ROOT)/docker/build
	docker build  \
		--tag ghcr.io/tprasadtp/virtio-whql \
		--output type=local,dest=$(REPO_ROOT)/docker/build \
		--file $(REPO_ROOT)/docker/Dockerfile \
		$(REPO_ROOT)/docker

.PHONY: clean
clean: ## clean
	rm -f $(REPO_ROOT)/docker/build/*.iso

.PHONY: changelog
changelog: ## Generate changelog
	git-chglog --repository-url=$(PROJECT_SOURCE) --output $(REPO_ROOT)/docs/changelog.md
