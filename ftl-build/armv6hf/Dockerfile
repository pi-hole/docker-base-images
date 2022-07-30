FROM debian:buster

# For FTL test compilation
ARG CI_ARCH="armv6hf"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

ARG idnversion=1.41
ARG readlineversion=8.1
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
        git \
    && rm -rf /var/lib/apt/lists/*

# Use cross-compiler from https://github.com/abhiTronix/raspberry-pi-cross-compilers
# Configuration: builder = any 64bit Linux
#                target = optimized for Raspberry Pi Zero, GCC version 10.3.0
RUN curl -sSL https://ftl.pi-hole.net/libraries/cross-gcc-10.3.0-pi_0-1.tar.gz | tar -xz
ENV PATH "/cross-pi-gcc-10.3.0-0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV LD_LIBRARY_PATH "/cross-pi-gcc-10.3.0-0/lib:/cross-pi-gcc-10.3.0-0/arm-linux-gnueabihf/libc/usr/lib/"

# We use the libnettle and libidn headers from the armel packages, however, we
# use the armv6 compatible libraries we built on a Raspberry Pi Zero
ENV CC "arm-linux-gnueabihf-gcc -isystem/usr/include -isystem/usr/include/arm-linux-gnueabi -isystem/usr/local/include"
RUN ln -s /cross-pi-gcc-10.3.0-0/arm-linux-gnueabihf/libc/usr/lib/libm.so /usr/local/lib/

# Download procompiled armv6 libraries
RUN wget https://ftl.pi-hole.net/libraries/libgmp.a -O /usr/local/lib/libgmp.a && \
    wget https://ftl.pi-hole.net/libraries/libnettle.a -O /usr/local/lib/libnettle.a && \
    wget https://ftl.pi-hole.net/libraries/libhogweed.a -O /usr/local/lib/libhogweed.a

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
