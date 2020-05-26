# pihole/docker-base-images

[![Image Builds](https://github.com/pi-hole/docker-base-images/workflows/Image%20Builds/badge.svg)](https://github.com/pi-hole/docker-base-images/actions)

Docker images used by other processes within pihole.

## Debian Base [![Docker Pulls](https://img.shields.io/docker/pulls/pihole/debian-base)](https://hub.docker.com/r/pihole/debian-base)

The pihole/docker-pi-hole aka docker image `pihole/pihole` uses this for x86 architecture's base for synolgoy compatibility

Tag Patterns:
* The standard `latest` tag, which is always in sync with the `master` branch
* Version tags, such as `v1.1`. Version tags are for a specific release of Dockerfile, however there are still regular builds to pull in changes from the base Debian layers, such as security updates.
* Branch based tags. These are always in sync with the branch matching the tag name and should only be used for testing and development purposes.
* Debian based tags: `buster`, `stretch`, `v1.1-buster`, `v1.1-stretch`, `dev-buster`, `dev-stretch`.

## FTL Images [![Docker Pulls](https://img.shields.io/docker/pulls/pihole/ftl-build)](https://hub.docker.com/r/pihole/ftl-build)

All the images used by the pihole/FTL repo to build the contents of that repo

Tag Patterns:
* Architecture tags, such as `x86_64` and `arm`. These are always the latest builds for the given architecture type
* Version tags with architecture, such as `v1.1-x86_64` and `v1.1-arm`. Version tags are for a specific release of Dockerfiles, however there are still regular builds to pull in changes from the base Debian layers, such as security updates.
* Branch based tags. These are always in sync with the branch matching the tag name and should only be used for testing and development purposes.

## Web Build Image [![Docker Pulls](https://img.shields.io/docker/pulls/pihole/web-build)](https://hub.docker.com/r/pihole/web-build)

Build image used by the [web repo](https://github.com/pi-hole/web)

## How does it get uploaded?

* GitHub Actions:
    * Every `push` event triggers a build
    * Schedule: 2:30am UTC every Sunday