FROM debian:buster AS builder

ARG idnversion=1.41
ARG readlineversion=8.1
ARG termcapversion=1.3.1
ARG nettleversion=3.9
ARG mbedtlsversion=3.4.0

RUN dpkg --add-architecture arm64 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        build-essential \
        gcc-aarch64-linux-gnu \
        libc-dev-arm64-cross \
        libcap-dev:arm64 \
        libcap2-bin \
        make \
        netcat-traditional \
        m4 \
        libgmp-dev:arm64 \
        ssh \
        sqlite3 \
        wget \
        binutils \
        cmake \
        libc6-dev:arm64 \
        xxd \
        jq \
        git \
        dnsutils \
        perl \
        python3 \
    && rm -rf /var/lib/apt/lists/*

ENV CC aarch64-linux-gnu-gcc -isystem /usr/local/include

RUN curl -sSL https://ftl.pi-hole.net/libraries/libidn-${idnversion}.tar.gz | tar -xz \
    && cd libidn-${idnversion} \
    && ./configure --host=aarch64-linux-gnueabi --enable-static --disable-shared --disable-doc --disable-valgrind-tests \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libidn-${idnversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --host=aarch64-linux-gnu --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --host=aarch64-linux-gnu --enable-static --disable-shared --disable-install-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --host=aarch64-linux-gnueabi --enable-static --disable-shared --disable-documentation \
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
ARG CI_ARCH="aarch64"
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
