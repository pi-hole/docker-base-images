# We cannot use buster here due to glibc version incompatibilities
FROM debian:stretch

# For FTL test compilation
ARG CI_ARCH="armv6hf"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

ARG idnversion=1.36
ARG readlineversion=8.0
ARG termcapversion=1.3.1

# Packages required to install compiler and libraries
RUN dpkg --add-architecture armel \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
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
        xxd \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Github actions/Checkout@v2 requires git >=2.18 else it will fall back to github API to download tarball
RUN echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update; \
    apt-get -t stretch-backports install git -y

# Use Raspbian's GCC
# This command was taken from https://github.com/dockcross/dockcross/blob/master/linux-armv6/Dockerfile
# Slightly modified from the original
RUN mkdir rpi_tools && cd rpi_tools && git init && git remote add origin https://github.com/raspberrypi/tools && \
    git config core.sparseCheckout true && \
    echo "arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf" >> .git/info/sparse-checkout && \
    git pull --depth=1 origin master && \
    cp -a arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/* /usr/ && rm -rf ../rpi_tools

# Download procompiled armv6 libraries
RUN wget https://ftl.pi-hole.net/libraries/libgmp.a -O /usr/local/lib/libgmp.a && \
    wget https://ftl.pi-hole.net/libraries/libnettle.a -O /usr/local/lib/libnettle.a && \
    wget https://ftl.pi-hole.net/libraries/libhogweed.a -O /usr/local/lib/libhogweed.a

# We use the libnettle and libidn headers from the armel packages, however, we
# use the armv6 compatible libraries we built on a Raspberry Pi Zero and
# uploaded them to ftl.pi-hole.net. Note that we do NOT include
# -L/usr/lib/arm-linux-gnueabihf here as this would result in incompatible binaries
ENV CC "arm-linux-gnueabihf-gcc -isystem /usr/include -isystem /usr/include/arm-linux-gnueabi -isystem /usr/local/include -L/usr/local/lib"
RUN ln -s /usr/arm-linux-gnueabihf/sysroot/usr/lib/libm.so /usr/local/lib/

RUN curl -sSL https://ftl.pi-hole.net/libraries/libidn-${idnversion}.tar.gz | tar -xz \
    && cd libidn-${idnversion} \
    && ./configure --host=armv6-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libidn-${idnversion}

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

# Test compile FTL's development branch, the result is removed from the final container
# We accept errors in the test step to be able to update the arch_tests if a change is intended
RUN git clone https://github.com/pi-hole/FTL.git \
    && cd FTL \
    && git checkout "${GIT_BRANCH}" \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && bash test/arch_test.sh \
    && cd .. \
    && rm -r FTL
