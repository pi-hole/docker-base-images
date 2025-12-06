FROM alpine:3.23 AS build

ARG TARGETPLATFORM
ARG readlineversion=8.3
ARG termcapversion=1.3.1
ARG nettleversion=3.10.2
ARG mbedtlsversion=3.6.4

RUN apk add --no-cache \
        alpine-sdk \
        bash \
        bind-tools \
        curl \
        gmp-dev \
        gmp-static \
        libcap \
        linux-headers \
        openssh-client \
        shadow \
        sqlite \
        binutils \
        cmake \
        xxd \
        jq \
        m4 \
        python3 \
        py3-yaml \
        zip \
        py3-requests \
        libidn2-dev \
        libidn2-static \
        libunistring-dev \
        libunistring-static \
        perl \
        clang \
        pdns \
        pdns-backend-sqlite3 \
        pdns-recursor \
        pdns-doc \
        gdb \
        py3-jinja2 \
        py3-jsonschema \
        ncurses \
        py3-dnspython

ENV STATIC=true
ENV TEST=true

# As of Alpine 3.21 (Dec 2024), we need to patch the termcap library to include
# the standard headers as well as unistd.h for the write function
RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --enable-static --disable-shared --disable-doc --without-examples \
    && sed -i '1i #define STDC_HEADERS 1\n#include <unistd.h>' termcap.c tparam.c \
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

RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --enable-static --disable-shared --disable-openssl --disable-mini-gmp -disable-gcov --disable-documentation \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r nettle-${nettleversion}

# Build static mbedTLS with pthread support
# Disable AESNI on linux/386 asit would possibly result in an incompatible
# binary in processors lacking the AESNI and SSE2 instruction sets
RUN curl -sSL https://ftl.pi-hole.net/libraries/mbedtls-${mbedtlsversion}.tar.bz2 | tar -xj \
    && cd mbedtls-${mbedtlsversion} \
    && sed -i '/#define MBEDTLS_THREADING_C/s*^//**g' include/mbedtls/mbedtls_config.h \
    && sed -i '/#define MBEDTLS_THREADING_PTHREAD/s*^//**g' include/mbedtls/mbedtls_config.h \
    && ( [ "${TARGETPLATFORM}" = "linux/386" ] \
         && echo "BUILDING WITHOUT AESNI SUPPORT" \
         && sed -i '/#define MBEDTLS_AESNI_C/s*^*//*g' include/mbedtls/mbedtls_config.h \
         || echo "BUILDING WITH AESNI SUPPORT" ) \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r mbedtls-${mbedtlsversion}

# Build static libbacktrace
RUN git clone https://github.com/ianlancetaylor/libbacktrace.git \
    && cd libbacktrace \
    && ./configure --enable-static --disable-shared \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libbacktrace

# Install bats-core directly into the build image
RUN git clone https://github.com/bats-core/bats-core.git

ENV BATS=/bats-core/bin/bats

FROM build AS test

# For FTL test compilation
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
ARG TARGETARCH
ARG TARGETVARIANT
ARG CI_ARCH="$TARGETPLATFORM"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

# Ensure that the TERM environment variable is set
ENV TERM=${TERM:-xterm}

# Monkeypatch BATS to remove duplicate output of starting and finished test
# BATS uses ANSI escape codes to overwrite the line after the test has finished
# This is not supported by Github Actions as it does not provide a TTY to the docker build container
RUN sed -i '/buffer_with_truncation /d' /bats-core/libexec/bats-core/bats-format-pretty

# Test compile FTL's development branch, the result is removed from the final container
# Run the full test suite to ensure that the container is still capable of running the tests
RUN git clone https://github.com/pi-hole/FTL.git --branch "${GIT_BRANCH}" \
    && cd FTL \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && readelf -A ./pihole-FTL \
    && readelf -l ./pihole-FTL \
    && bash test/arch_test.sh \
    && bash test/run.sh \
    && cd .. \
    && rm -r FTL
