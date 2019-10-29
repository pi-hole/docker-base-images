# pihole/docker-base-images

Docker images used by other processes within pihole

## What is here?

- debian-base: The pihole/docker-pi-hole aka docker image `pihole/pihole` uses this for x86 architecture's base for synolgoy compatiblity
  - TODO: upgrade to buster and perhaps we don't even need to disable auditd anymore? Needs investigation
- ftl-build: All of the images used by the pihole/FTL repo to build the contents of that repo

## How does it get uploaded

CircleCI magic.

