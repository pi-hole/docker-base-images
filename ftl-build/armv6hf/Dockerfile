FROM debian:buster

# ghr 0.13.0 2019-09-16
ARG ghrversion=0.13.0

ARG readlineversion=8.0
ARG termcapversion=1.3.1

# Packages required to install compiler and libraries
RUN dpkg --add-architecture armel \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    git \
    ca-certificates \
    curl \
    make \
    file \
    netcat-traditional \
    ssh \
    sqlite3 \
    dnsutils \
    binutils \
    cmake \
    nettle-dev:armel \
    libcap-dev:armel \
    libgmp-dev:armel \
    libc6-dev:armel \
    && rm -rf /var/lib/apt/lists/*

# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN curl -sSL https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
    tar --strip-components=1 -C /usr/bin/ -xz \
    ghr_v${ghrversion}_linux_amd64/ghr

# Use Raspbian's GCC
# This command was taken from https://github.com/dockcross/dockcross/blob/master/linux-armv6/Dockerfile
# Slightly modified from the original
RUN mkdir rpi_tools && cd rpi_tools && git init && git remote add origin https://github.com/raspberrypi/tools && \
    git config core.sparseCheckout true && \
    echo "arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf" >> .git/info/sparse-checkout && \
    git pull --depth=1 origin master && \
    cp -a arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/* /usr/ && rm -rf ../rpi_tools

# Download procompiled armv6 libraries
RUN wget ftl.pi-hole.net/libraries/libgmp.a -O /usr/local/lib/libgmp.a && \
    wget ftl.pi-hole.net/libraries/libnettle.a -O /usr/local/lib/libnettle.a && \
    wget ftl.pi-hole.net/libraries/libhogweed.a -O /usr/local/lib/libhogweed.a

# We use the libnettle and libidn headers from the armel packages, however, we
# use the armv6 compatible libraries we built on a Raspberry Pi Zero and
# uploaded them to ftl.pi-hole.net. Note that we do NOT include
# -L/usr/lib/arm-linux-gnueabihf here as this would result in incompatible binaries
ENV CC "arm-linux-gnueabihf-gcc -isystem /usr/include -isystem /usr/include/arm-linux-gnueabi -isystem /usr/local/include -L/usr/local/lib"
RUN ln -s /usr/arm-linux-gnueabihf/sysroot/usr/lib/libm.so /usr/local/lib/

# Download and cross-compile libidn, we prevent the examples from being built as they will not
# run on the x86_64 host and lead to errors
RUN curl -sSL https://ftp.gnu.org/gnu/libidn/libidn-1.35.tar.gz | tar -xz && \
    cd libidn-1.35 && ./configure --host=armv6-linux-gnueabi --disable-shared --disable-doc --without-examples && \
    make -j $(nproc) install

RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --host=armv6-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --host=armv6-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

# Uncomment the following line to test-compile FTL master during docker container development
# RUN git clone https://github.com/pi-hole/FTL.git && cd FTL && git checkout development \
#     && bash build.sh -DLUA_READLINE=true && readelf -A ./pihole-FTL
