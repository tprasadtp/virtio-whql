# If SHELL is sh change it to bash
ifeq ($(SHELL),/bin/sh)
	SHELL := /bin/bash
endif

export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Set default goal to help
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this message
	@printf "%-20s %s\n" "Target" "Help"
	@printf "%-20s %s\n" "-----" "-----"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build and Extract
	@echo "-> Building VirtIO ISO via Docker"
	docker \
		build \
        --tag ghcr.io/tprasadtp/dev-virtio-whql \
        --output type=local,dest=docker/build \
        docker

.PHONY: verify
verify: ## Verify ISO (Requires Windows)
	@echo "-> Verifying ISO"
	powershell scripts/verify.ps1

.PHONY: release
release: ## Release
	@echo "-> Verifying ISO"
	bash scripts/release.sh

.PHONY: clean
clean: ## Clean
	@echo "-> Cleaning Build artifacts"
	rm -f $(REPO_ROOT)/docker/build/VERSION.txt
	rm -f $(REPO_ROOT)/docker/build/virtio-win.iso
	rm -f $(REPO_ROOT)/docker/build/virtio-win.iso.sha256
	rm -f $(REPO_ROOT)/docker/build/virtio-winpe.iso
	rm -f $(REPO_ROOT)/docker/build/virtio-winpe.iso.sha256
	rm -f $(REPO_ROOT)/docker/build/virtio-win-guest-tools.exe
	rm -f $(REPO_ROOT)/docker/build/virtio-win-guest-tools.exe.sha256
