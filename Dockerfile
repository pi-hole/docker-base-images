FROM debian:stretch-slim
COPY create_pam_debians.sh /
RUN bash -ex /create_pam_debians.sh

FROM debian:stretch-slim
COPY --from=0 /tmp/*.deb /
ENV S6OVERLAY_RELEASE https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz
COPY setup.sh /usr/local/bin/setup.sh
RUN bash -ex setup.sh 2>&1
