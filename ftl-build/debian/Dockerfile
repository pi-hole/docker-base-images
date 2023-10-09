# This container currently defaults to stretch as there is no linux/arm/v5 image for buster
ARG CONTAINER="debian:bullseye-slim"
FROM ${CONTAINER} AS builder

ARG CONTAINER
ARG idnversion=1.41
ARG readlineversion=8.1
ARG termcapversion=1.3.1
ARG nettleversion=3.9.1
ARG mbedtlsversion=3.4.1
ARG libunwindversion=1.6.2

# Switch repositories to the archive server
RUN if [ "${CONTAINER}" = "debian:stretch-slim" ]; then \
         sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
      && sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list \
      && sed -i '/stretch-updates/d' /etc/apt/sources.list \
      && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until; \
    fi

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        build-essential \
        m4 \
        libgmp-dev \
        libcap-dev \
        libcap2-bin \
        make \
        netcat-traditional \
        ssh \
        wget \
        binutils \
        cmake \
        xxd \
        jq \
        git \
        python3 \
    && rm -rf /var/lib/apt/lists/*

#We cannot test as we do powerdns packages for Debian != amd64
ENV TEST false

RUN curl -sSL https://ftl.pi-hole.net/libraries/libidn-${idnversion}.tar.gz | tar -xz \
    && cd libidn-${idnversion} \
    && ./configure --enable-static --disable-shared --disable-doc --disable-valgrind-tests \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libidn-${idnversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --enable-static --disable-shared --disable-install-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

# --disable-assembler is required for building armv4T binaries (otherwise, the
# aes and sha components will be armv6 forcing the entire library to be armv6)
# This is not relevant for Pi-hole as we are not using AES in FTL and SHA can
# be provided by software
RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --enable-static --disable-shared --disable-openssl --disable-mini-gmp -disable-gcov --disable-documentation --disable-assembler \
    && make -j $(nproc) install \
    && cd .. \
    && rm -rf nettle-${nettleversion}

# Build static mbedTLS with pthread support
RUN curl -sSL https://ftl.pi-hole.net/libraries/mbedtls-${mbedtlsversion}.tar.gz | tar -xz \
    && cd mbedtls-${mbedtlsversion} \
    && sed -i '/#define MBEDTLS_THREADING_C/s*^//**g' include/mbedtls/mbedtls_config.h \
    && sed -i '/#define MBEDTLS_THREADING_PTHREAD/s*^//**g' include/mbedtls/mbedtls_config.h \
    && make -j $(nproc) install \
    && cd .. \
    && rm -rf mbedtls-${mbedtlsversion}

# Build static libunwind
RUN curl -sSL https://ftl.pi-hole.net/libraries/libunwind-${libunwindversion}.tar.gz | tar -xz \
    && cd libunwind-${libunwindversion} \
    && ./configure --enable-static --disable-shared --disable-tests --disable-documentation \
    && make -j $(nproc) install \
    && cd .. \
    && rm -rf libunwind-${libunwindversion}

# Install bats-core directly into the build image
RUN git clone https://github.com/bats-core/bats-core.git

ENV BATS=/bats-core/bin/bats

FROM builder AS tester

# For FTL test compilation
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
ARG CI_ARCH="$TARGETPLATFORM"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

# Test compile FTL's development branch, the result is removed from the final container
# Run the full test suite to ensure that the container is still capable of running the tests
RUN git clone https://github.com/pi-hole/FTL.git --branch "${GIT_BRANCH}" \
    && cd FTL \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && readelf -A ./pihole-FTL \
    && readelf -l ./pihole-FTL \
    && ldd -r -v ./pihole-FTL \
    && bash test/arch_test.sh \
    && bash test/run.sh \
    && cd .. \
    && rm -r FTL
