FROM debian:stretch

# ghr 0.13.0 2019-09-16
ARG ghrversion=0.13.0

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        dnsutils \
        file \
        gcc \
        gcc-multilib \
        git \
        libcap2-bin \
        libcap-dev:i386 \
        libidn11-dev:i386 \
        make \
        netcat-traditional \
        nettle-dev:i386 \
        sqlite3 \
        ssh \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN curl -sSL https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
    tar --strip-components=1 -C /usr/bin/ -xz \
    ghr_v${ghrversion}_linux_amd64/ghr

ENV CC "gcc -m32"
