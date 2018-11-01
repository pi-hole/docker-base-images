#!/bin/bash -ex
# Seperated specifically to enable easy modificaiton of Dockerfile to cache this really long step

# Install pam requirements
apt-get update
apt-get install -y libc6-dev libc-dev

# From file from earlier docker file
# https://github.com/pi-hole/docker-pi-hole/issues/243
dpkg -i libpam-doc*.deb libpam-modules*.deb libpam-runtime*.deb libpam0g*.deb
rm /*.deb
rm -rf /var/cache/apt/archives /var/lib/apt/lists/*
