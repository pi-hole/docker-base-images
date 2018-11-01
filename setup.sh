#!/bin/bash -ex
# Seperated specifically to enable easy modificaiton of Dockerfile to cache this really long step

# Install s6 and pam requirements
apt-get update
apt-get install -y curl procps libc6-dev libc-dev
curl -L -s $S6OVERLAY_RELEASE | tar xvzf - -C /
mv /init /s6-init

# From file from earlier docker file
# https://github.com/pi-hole/docker-pi-hole/issues/243
dpkg -i libpam-doc*.deb libpam-modules*.deb libpam-runtime*.deb libpam0g*.deb
rm /*.deb
