# pihole/docker-base-images

[![Image Builds](https://github.com/pi-hole/docker-base-images/workflows/Image%20Builds/badge.svg)](https://github.com/pi-hole/docker-base-images/actions)

Docker images used by other processes within pihole.

---
# Debian Base [![Docker Pulls](https://img.shields.io/docker/pulls/pihole/debian-base)](https://hub.docker.com/r/pihole/debian-base)

The pihole/docker-pi-hole aka docker image `pihole/pihole` uses this for x86 architecture's base for synolgoy compatibility

Tag Patterns:

- The standard `latest` tag, which is always in sync with the `master` branch
- Version tags, such as `v1.1`. Version tags are for a specific release of Dockerfile, however there are still regular builds to pull in changes from the base Debian layers, such as security updates.
- Branch based tags. These are always in sync with the branch matching the tag name and should only be used for testing and development purposes.
- Debian based tags: `buster`, `stretch`, `v1.1-buster`, `v1.1-stretch`, `dev-buster`, `dev-stretch`.

## How does it get uploaded?

- GitHub Actions:
  - Every `push` event triggers a build
  - Schedule: 2:30am UTC every Sunday

---
# FTL Images [![Docker Pulls](https://img.shields.io/docker/pulls/pihole/ftl-build)](https://hub.docker.com/r/pihole/ftl-build)

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
  - Every `tag` event (e.g `v1`) triggers a build and uploads both a `${arch}` and `v1-${arch}` image
  - Schedule: 1:30am UTC every Sunday a build is triggered and a `${arch}` is uploaded

