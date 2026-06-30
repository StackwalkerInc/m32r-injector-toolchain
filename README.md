# m32r-injector-toolchain

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Docker image providing a `m32r-elf` cross-compiler (GCC), CMake, and [codeinjector](https://github.com/StackwalkerInc/codeinjector) for bare-metal M32R development.

Published to: `ghcr.io/stackwalkerinc/m32r-injector-toolchain`

## Defaults

| Component       | Version |
|-----------------|---------|
| GCC             | 16.1.0  |
| binutils        | 2.44    |
| codeinjector    | 0.1.2   |
| Ubuntu          | 24.04   |

## Pull the image

```sh
docker pull ghcr.io/stackwalkerinc/m32r-injector-toolchain:latest
```

## Use as a build environment

```sh
docker run --rm -v "$PWD":/work -w /work \
  ghcr.io/stackwalkerinc/m32r-injector-toolchain:latest \
  m32r-elf-gcc -o hello hello.c
```

## Build locally

```sh
make build
# override versions
make build GCC_VERSION=14.2.0 BINUTILS_VERSION=2.43 CODEINJECTOR_VERSION=0.0.1
```

## Release a new image version

Push a tag:

```sh
git tag v1.0.0
git push origin v1.0.0
```

Or trigger `workflow_dispatch` manually from GitHub Actions with optional version overrides.
