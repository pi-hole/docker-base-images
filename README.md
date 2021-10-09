# pihole/docker-base-images

Docker images used by other processes within pihole.

---
# Debian Base [![Docker Pulls](https://img.shields.io/docker/pulls/pihole/debian-base)](https://hub.docker.com/r/pihole/debian-base) [![Image Builds](https://github.com/pi-hole/docker-base-images/actions/workflows/debian-base.yml/badge.svg)](https://github.com/pi-hole/docker-base-images/actions/workflows/debian-base.yml)

The pihole/docker-pi-hole aka docker image `pihole/pihole` uses this for x86 architecture's base for synolgoy compatibility

Tag Patterns:

- `latest` tag: This is always the most recently tagged / scheduled build of `buster`
- Debian flavour tags: `stretch`, `buster`, `bullseye`. These are always the latest builds for the given flavour.
- Version tags with Debian flavour, such as `v1.1-buster`. Version tags are for a specific release of Dockerfile, however there are still regular builds to pull in changes from the base Debian layers, such as security updates.
- Branch based tags. These are always in sync with the branch matching the tag name and should only be used for testing and development purposes.

## How does it get uploaded?

- GitHub Actions (`debian-base.yml`):
  - Every `pull_request` event triggers a build (but does not push)
  - Every `workflow_dispatch` event triggers a build of the branch it is run against, and uploads a branch-based tag
  - Every `tag` event (e.g `v1`) triggers a build and uploads both `${{matrix.DEBIAN_VERSION}}` and `v1-${{matrix.DEBIAN_VERSION}}` tags
  - Schedule: 2:30am UTC every Sunday a build is triggered and a `${{matrix.DEBIAN_VERSION}}` tag is uploaded

---
# FTL Images [![Docker Pulls](https://img.shields.io/docker/pulls/pihole/ftl-build)](https://hub.docker.com/r/pihole/ftl-build) [![Image Builds](https://github.com/pi-hole/docker-base-images/actions/workflows/ftl-build.yml/badge.svg)](https://github.com/pi-hole/docker-base-images/actions/workflows/ftl-build.yml)

All the images used by the pihole/FTL repo to build the contents of that repo

Tag Patterns:
 - Architecture tags, such as `x86_64` and `armv4t`. These are always the latest builds for the given architecture type
 - Version tags with architecture, such as `v1.1-x86_64` and `v1.1-armv4t`. Version tags are for a specific release of Dockerfiles, however there are still regular builds to pull in changes from the base Debian layers, such as security updates.
 - Branch based tags. These are built against the branch matching the tag name and should only be used for testing and development purposes.

All images are pushed to both Docker Hub (`pihole/ftl-build`) and GHCR (`ghcr.io/pi-hole/ftl-build`)

## How does it get uploaded?

- GitHub Actions (`ftl-build.yml`):
  - Every `pull_request` event triggers a build (but does not push)
  - Every `workflow_dispatch` event triggers a build of the branch it is run against, and uploads a branch-based tag
  - Every `tag` event (e.g `v1`) triggers a build and uploads both `${{matrix.ARCH}}` and `v1-${{matrix.ARCH}}` tags
  - Schedule: 1:30am UTC every Sunday a build is triggered and a `${{matrix.ARCH}}` tag is uploaded

