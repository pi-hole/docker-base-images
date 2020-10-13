FROM debian:buster

# ghr 0.13.0 2019-09-16
ARG ghrversion=0.13.0

ARG idnversion=1.36
ARG readlineversion=8.0
ARG termcapversion=1.3.1

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
        make \
        netcat-traditional \
        nettle-dev:armhf \
        ssh \
        sqlite3 \
        wget \
        binutils \
        cmake \
        libc6:armhf \
    && rm -rf /var/lib/apt/lists/*
    
# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN curl -sSL https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
    tar --strip-components=1 -C /usr/bin/ -xz \
    ghr_v${ghrversion}_linux_amd64/ghr

ENV CC "arm-linux-gnueabihf-gcc -isystem /usr/local/include"
RUN ln -s /usr/arm-linux-gnueabihf/lib/libm.so /usr/local/lib/

RUN curl -sSL https://ftl.pi-hole.net/libraries/libidn-${idnversion}.tar.gz | tar -xz \
    && cd libidn-${idnversion} \
    && ./configure --host=armv7-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libidn-${idnversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --host=armv7-linux-gnueabihf --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --host=armv7-linux-gnueabihf --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

# Uncomment the following line to test-compile FTL development during docker container development
RUN git clone https://github.com/pi-hole/FTL.git && cd FTL && git checkout development \
    && bash build.sh -DLUA_READLINE=true && readelf -A ./pihole-FTL
