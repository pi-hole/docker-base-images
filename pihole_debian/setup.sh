#!/bin/bash -ex
# Seperated specifically to enable easy modificaiton of Dockerfile to cache this really long step

# From file from earlier docker file
# https://github.com/pi-hole/docker-pi-hole/issues/243
dpkg -i libpam-modules_*.deb \
        libpam-modules-bin_*.deb \
        libpam-runtime_*.deb \
        libpam0g_*.deb

# Hold patched packages so users don't accidently unpatch the image with
# apt-get upgrade
apt-mark hold libpam-modules
apt-mark hold libpam-modules-bin
apt-mark hold libpam-runtime
apt-mark hold libpam0g

rm /*.deb
