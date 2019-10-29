FROM debian:stretch-slim
COPY create_pam_debians.sh /usr/local/bin/
RUN bash -ex create_pam_debians.sh

FROM debian:stretch-slim
WORKDIR /usr/local/repos/pam
COPY --from=0 /tmp/*.deb ./
COPY create_local_pam_repo.sh /usr/local/bin
RUN bash -ex create_local_pam_repo.sh

FROM debian:stretch-slim
COPY --from=0 /tmp/*.deb /
COPY --from=1 /etc/apt/ /etc/apt/
COPY --from=1 /usr/local/repos/pam /usr/local/repos/pam
COPY setup.sh /usr/local/bin/
RUN bash -ex setup.sh && rm /usr/local/bin/setup.sh

FROM scratch
COPY --from=2 / /
