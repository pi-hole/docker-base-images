ARG DEBIAN_VERSION=buster
FROM debian:${DEBIAN_VERSION}-slim as pam_debians
COPY create_pam_debians.sh /usr/local/bin/
RUN bash -ex create_pam_debians.sh

FROM debian:${DEBIAN_VERSION}-slim as local_pam_repo
WORKDIR /usr/local/repos/pam
COPY --from=pam_debians /tmp/*.deb ./
COPY create_local_pam_repo.sh /usr/local/bin
RUN bash -ex create_local_pam_repo.sh

FROM debian:${DEBIAN_VERSION}-slim
COPY --from=pam_debians /tmp/*.deb /
COPY --from=local_pam_repo /etc/apt/ /etc/apt/
COPY --from=local_pam_repo /usr/local/repos/pam /usr/local/repos/pam
COPY setup.sh /usr/local/bin/
RUN bash -ex setup.sh && rm /usr/local/bin/setup.sh
