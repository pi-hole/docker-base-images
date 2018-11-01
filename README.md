# Debian docker with a custom pam build

Custom pam rebuilt with `--disable-audit` to help older kernel machines like synology that may not have the option to upgrade their kernel.

- Docker/Moby bug details: https://github.com/moby/moby/issues/5899
- Based off : [sequenceiq/pam](https://github.com/sequenceiq/docker-pam/)
- [docker-pi-hole issue #243](https://github.com/pi-hole/docker-pi-hole/issues/243)
