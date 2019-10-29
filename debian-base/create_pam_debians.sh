#!/bin/bash -ex
# https://github.com/pi-hole/docker-pi-hole/issues/243
# fix error AUDIT: Allow login in non-init namespaces
# Credit to https://github.com/sequenceiq/docker-pam/blob/master/ubuntu-14.04/Dockerfile
srclist="/etc/apt/sources.list"
cat $srclist | while read line; do
  srcline="$(echo $line | sed 's/deb/deb-src/')"
  echo "$srcline" >> $srclist
done;

apt-get update

cd /tmp
apt-get -s -y build-dep pam > builddeps.txt
apt-get -y build-dep pam

export CONFIGURE_OPTS=--disable-audit
apt-get -b source pam
rm -rf /var/cache/apt/archives /var/lib/apt/lists/*
