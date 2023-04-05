# Note that this has to stay at stretch as buster removed ARMv4T compatibility
FROM debian:stretch AS builder

ARG idnversion=1.41
ARG readlineversion=8.1
ARG termcapversion=1.3.1
ARG nettleversion=3.8.1
ARG mbedtlsversion=3.4.0

RUN dpkg --add-architecture armel \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        build-essential \
        gcc-arm-linux-gnueabi \
        libc6-dev-armel-cross \
        libcap-dev:armel \
        libcap2-bin \
        libidn11-dev:armel \
        make \
        netcat-traditional \
        libgmp-dev:armel \
        m4 \
        ssh \
        sqlite3 \
        wget \
        binutils \
        cmake \
        libc6:armel \
        xxd \
        jq \
        perl \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# Github actions/Checkout@v2 requires git >=2.18 else it will fall back to github API to download tarball
# stretch-backports also has dnsutils 9.11.5, which has support for +unknown (See https://github.com/pi-hole/FTL/pull/1223#discussion_r731148277)
RUN echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get -t stretch-backports install --no-install-recommends -y \
        git \
        dnsutils \
    && rm -rf /var/lib/apt/lists/*

ENV CC "arm-linux-gnueabi-gcc -isystem /usr/local/include"
RUN ln -s /usr/arm-linux-gnueabi/lib/libm.so /usr/local/lib/

RUN curl -sSL https://ftl.pi-hole.net/libraries/libidn-${idnversion}.tar.gz | tar -xz \
    && cd libidn-${idnversion} \
    && ./configure --host=arm-linux-gnueabi --enable-static --disable-shared --disable-doc --disable-valgrind-tests \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libidn-${idnversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --host=arm-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --host=arm-linux-gnueabi --enable-static --disable-shared --disable-install-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --host=arm-linux-gnueabi --enable-static --disable-shared --disable-fat --disable-documentation \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r nettle-${nettleversion}

# Build static mbedTLS with pthread support
RUN curl -sSL https://ftl.pi-hole.net/libraries/mbedtls-${mbedtlsversion}.tar.gz | tar -xz \
    && cd mbedtls-${mbedtlsversion} \
    && sed -i '/#define MBEDTLS_THREADING_C/s*^//**g' include/mbedtls/mbedtls_config.h \
    && sed -i '/#define MBEDTLS_THREADING_PTHREAD/s*^//**g' include/mbedtls/mbedtls_config.h \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r mbedtls-${mbedtlsversion}

FROM builder AS tester

# For FTL test compilation
ARG CI_ARCH="armv4t"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

# Test compile FTL's development branch, the result is removed from the final container
# We accept errors in the test step to be able to update the arch_tests if a change is intended
RUN git clone https://github.com/pi-hole/FTL.git \
    && cd FTL \
    && git checkout "${GIT_BRANCH}" \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && bash test/arch_test.sh \
    && cd .. \
    && rm -r FTL
