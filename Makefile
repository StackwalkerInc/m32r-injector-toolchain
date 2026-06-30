IMAGE                ?= m32r-toolchain
GCC_VERSION          ?= 16.1.0
BINUTILS_VERSION     ?= 2.44
UBUNTU_VERSION       ?= 24.04
CODEINJECTOR_VERSION ?= 0.1.2

# Resolve the codeinjector tag to a SHA. Pinning the build to a SHA (not
# a tag) prevents stale Docker layer caches from silently reusing a binary
# built from an older state of the tag.
CODEINJECTOR_SHA = $(shell git ls-remote https://github.com/StackwalkerInc/codeinjector.git refs/tags/v$(CODEINJECTOR_VERSION) | cut -f1)

BUILD_ARGS = \
	--build-arg GCC_VERSION=$(GCC_VERSION) \
	--build-arg BINUTILS_VERSION=$(BINUTILS_VERSION) \
	--build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
	--build-arg CODEINJECTOR_VERSION=$(CODEINJECTOR_VERSION) \
	--build-arg CODEINJECTOR_SHA=$(CODEINJECTOR_SHA)

.PHONY: build shell push smoke check-sha

check-sha:
	@if [ -z "$(CODEINJECTOR_SHA)" ]; then \
		echo "ERROR: could not resolve codeinjector tag v$(CODEINJECTOR_VERSION) to a SHA"; \
		exit 1; \
	fi

build: check-sha
	docker buildx build \
		$(BUILD_ARGS) \
		--load \
		-t $(IMAGE):latest \
		.

shell:
	docker run --rm -it $(IMAGE):latest /bin/bash

smoke:
	docker run --rm -v "$(CURDIR)/tests/smoke:/smoke:ro" $(IMAGE):latest /smoke/run.sh

push: check-sha
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		$(BUILD_ARGS) \
		--push \
		-t $(IMAGE):latest \
		.
