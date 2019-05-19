FROM debian:stretch-slim
COPY create_pam_debians.sh /usr/local/bin/
RUN bash -ex create_pam_debians.sh

FROM debian:stretch-slim
COPY --from=0 /tmp/*.deb /
COPY setup.sh /usr/local/bin/
RUN bash -ex setup.sh && rm /usr/local/bin/setup.sh

FROM scratch
COPY --from=1 / /
