FROM debian:buster

# Packages required to install compiler and libraries
RUN dpkg --add-architecture armel \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    git \
    ca-certificates \
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
    && rm -rf /var/lib/apt/lists/*

# ghr 0.13.0 2019-09-16
ARG ghrversion=0.13.0

# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN wget -O - https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
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
ENV CC "arm-linux-gnueabihf-gcc -I/usr/include -I/usr/include/arm-linux-gnueabi -I/usr/local/include -L/usr/local/lib"

# Download and cross-compile libidn, we prevent the examples from being built as they will not
# run on the x86_64 host and lead to errors
RUN wget https://ftp.gnu.org/gnu/libidn/libidn-1.35.tar.gz && tar -xzf libidn-1.35.tar.gz && \
    cd libidn-1.35 && ./configure --host=armv6-linux-gnueabi --disable-shared --disable-doc --without-examples && \
    make -j $(nproc) install

# Uncomment the following line to test-compile FTL master during docker container development
# RUN git clone https://github.com/pi-hole/FTL.git && cd FTL && git checkout development && make -j $(nproc) && readelf -A ./pihole-FTL
