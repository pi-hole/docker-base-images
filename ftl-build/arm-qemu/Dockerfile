FROM multiarch/debian-debootstrap:armel-stretch-slim

ARG nettleversion=3.4
ARG readlineversion=8.0
ARG termcapversion=1.3.1

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        dnsutils \
        git \
        libcap2-bin \
        libgmp-dev \
        libidn11-dev \
        m4 \
        binutils \
        cmake \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --host=armv5-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make \
    && make install \
    && cd .. \
    && rm -r nettle-${nettleversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --host=armv5-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --host=armv5-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

# Uncomment the following line to test-compile FTL master during docker container development
#RUN git clone https://github.com/pi-hole/FTL.git && cd FTL && git checkout development \
#    && bash build.sh -DLUA_READLINE=true && readelf -A ./pihole-FTL
