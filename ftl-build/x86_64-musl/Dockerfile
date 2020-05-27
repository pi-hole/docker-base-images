FROM alpine:3.10

# ghr 0.13.0 2019-09-16
ARG ghrversion=0.13.0

RUN apk add --no-cache \
        alpine-sdk \
        bash \
        bind-tools \
        wget \
        gmp-dev \
        libcap \
        libidn-dev \
        linux-headers \
        nettle-dev \
        openssh-client \
        shadow \
        sqlite \
        binutils \
        cmake

# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN wget -O - https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
    tar --strip-components=1 -C /usr/bin/ -xz \
    ghr_v${ghrversion}_linux_amd64/ghr

ENV CC gcc
ENV STATIC true
