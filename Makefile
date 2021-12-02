SHELL := /bin/bash
export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: help
help: ## This help message
	@printf "%-20s %s\n" "Target" "Help"
	@printf "%-20s %s\n" "-----" "-----"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: clean ## Build ISO
	@mkdir -p $(REPO_ROOT)/docker/build
	DOCKER_BUILDKIT=1 docker build  \
		--tag ghcr.io/tprasadtp/virtio-whql \
		--output type=local,dest=$(REPO_ROOT)/docker/build \
		--file $(REPO_ROOT)/docker/Dockerfile \
		$(REPO_ROOT)/docker

.PHONY: clean
clean: ## clean
	rm -f $(REPO_ROOT)/docker/build/*.iso
	rm -f $(REPO_ROOT)/docker/build/VERSION.txt

.PHONY: changelog
changelog: ## Generate changelog
	git-chglog --repository-url=https://github.com/tprasadtp/virtio-whql --output $(REPO_ROOT)/CHANGELOG.md
