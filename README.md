# pihole/docker-base-images

Docker images used by other processes within pihole.
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

# Docker Pi-hole Base Images [![Docker Pulls](https://img.shields.io/docker/pulls/pihole/docker-pi-hole-base)](https://hub.docker.com/r/pihole/docker-pi-hole-base) [![Image Builds](https://github.com/pi-hole/docker-base-images/actions/workflows/docker-pi-hole-base.yml/badge.svg)](https://github.com/pi-hole/docker-base-images/actions/workflows/docker-pi-hole-base.yml)

All the images used by the pihole/docker-pi-hole repo to build the contents of that repo

Tag Patterns:
 - Multiarch Debian Version tags, such as `buster-slim` and `bullseye-slim`. These are always the latest builds for the given debian version

All images are pushed to both Docker Hub (`pihole/docker-pi-hole-base`) and GHCR (`ghcr.io/pi-hole/docker-pi-hole-base`)

## How does it get uploaded?

- GitHub Actions (`docker-pi-hole-base.yml`):
  - Every `pull_request` event triggers a build (but does not push)
  - Every `workflow_dispatch` event triggers a build of the branch it is run against, and uploads a branch-based tag
  - Schedule: 1:30am UTC every Sunday a build is triggered and a `${{matrix.ARCH}}` tag is uploaded
