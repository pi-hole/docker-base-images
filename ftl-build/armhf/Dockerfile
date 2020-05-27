FROM debian:buster

# ghr 0.13.0 2019-09-16
ARG ghrversion=0.13.0

RUN dpkg --add-architecture armhf \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        dnsutils \
        file \
        gcc-arm-linux-gnueabihf \
        git \
        libc6-dev-armhf-cross \
        libcap-dev:armhf \
        libcap2-bin \
        libidn11-dev:armhf \
        make \
        netcat-traditional \
        nettle-dev:armhf \
        ssh \
        sqlite3 \
        wget \
        binutils \
        cmake \
    && rm -rf /var/lib/apt/lists/*
    
# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN curl -sSL https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
    tar --strip-components=1 -C /usr/bin/ -xz \
    ghr_v${ghrversion}_linux_amd64/ghr

ENV CC arm-linux-gnueabihf-gcc
