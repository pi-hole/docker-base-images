FROM alpine:3.24 AS build

ARG TARGETPLATFORM
ARG readlineversion=8.3
ARG termcapversion=1.3.1-patched
ARG nettleversion=3.10.2
ARG mbedtlsversion=4.0.0
ARG opensslversion=3.5.7
ARG BATS_CORE_VER=v1.13.0
ARG BATS_SUPPORT_VER=v0.3.0
ARG BATS_ASSERT_VER=v2.2.4
ARG BATS_FILE_VER=v0.4.0

RUN apk add --no-cache \
        alpine-sdk \
        bash \
        bind-tools \
        binutils \
        clang \
        cmake \
        curl \
        gdb \
        gmp-dev \
        gmp-static \
        jq \
        libcap \
        libidn2-dev \
        libidn2-static \
        libunistring-dev \
        libunistring-static \
        linux-headers \
        m4 \
        ncurses \
        openssh-client \
        pdns \
        pdns-backend-sqlite3 \
        pdns-doc \
        pdns-recursor \
        perl \
        py3-dnspython \
        py3-jinja2 \
        py3-jsonschema \
        py3-pytest \
        py3-requests \
        py3-yaml \
        python3 \
        shadow \
        sqlite \
        xxd \
        zip

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
    && sed -i '/#define MBEDTLS_THREADING_C/s*^//**g' tf-psa-crypto/include/psa/crypto_config.h \
    && sed -i '/#define MBEDTLS_THREADING_PTHREAD/s*^//**g' tf-psa-crypto/include/psa/crypto_config.h \
    && ( [ "${TARGETPLATFORM}" = "linux/386" ] \
         && echo "BUILDING WITHOUT AESNI SUPPORT" \
         && sed -i '/#define MBEDTLS_AESNI_C/s*^*//*g' include/mbedtls/mbedtls_config.h \
         || echo "BUILDING WITH AESNI SUPPORT" ) \
    && cmake -S . -B build -DCMAKE_C_FLAGS="-fomit-frame-pointer" \
    && cmake --build build -j $(nproc) \
    && cmake --install build \
    && cd .. \
    && rm -r mbedtls-${mbedtlsversion}

# Build static OpenSSL 3.5 LTS (TLS for civetweb + DoT/DoH, and native QUIC for
# the future DoQ/DoH3 work).
# Trimmed for binary size: drop the legacy provider, unused protocols/ciphers,
# engines and DSO. QUIC stays enabled (default in 3.5). no-deprecated is left
# off on purpose: it saves very little and would require a civetweb patch
# (SSL_library_init, SSL_get_peer_certificate) to keep compiling.
# TODO: pull from the ftl.pi-hole.net mirror (like the other libs) once the
# tarball is uploaded there; using the upstream release directly for now.
RUN curl -sSL https://github.com/openssl/openssl/releases/download/openssl-${opensslversion}/openssl-${opensslversion}.tar.gz | tar -xz \
    && cd openssl-${opensslversion} \
    && ./config \
        no-shared no-tests no-docs no-apps \
        no-legacy no-comp no-dtls no-ssl3 \
        no-psk no-srp no-idea no-rc2 no-rc4 no-rc5 no-md4 no-mdc2 no-whirlpool \
        no-engine no-dso \
        --prefix=/usr/local --libdir=lib --openssldir=/usr/local/ssl \
    && make -j $(nproc) \
    && make install_dev \
    && ls -l /usr/local/lib/libssl.a /usr/local/lib/libcrypto.a \
    && cd .. \
    && rm -r openssl-${opensslversion}

# Build static libbacktrace
RUN git clone https://github.com/ianlancetaylor/libbacktrace.git \
    && cd libbacktrace \
    && ./configure --enable-static --disable-shared \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libbacktrace

# Install bats-core directly into the build image
RUN git clone --depth=1 --single-branch --branch "${BATS_CORE_VER}" https://github.com/bats-core/bats-core.git /bats/bats-core \
  && git clone --depth=1 --single-branch --branch "${BATS_SUPPORT_VER}" https://github.com/bats-core/bats-support /bats/bats-support \
  && git clone --depth=1 --single-branch --branch "${BATS_ASSERT_VER}" https://github.com/bats-core/bats-assert  /bats/bats-assert \
  && git clone --depth=1 --single-branch --branch "${BATS_FILE_VER}" https://github.com/bats-core/bats-file    /bats/bats-file
ENV BATS=/bats/bats-core/bin/bats
ENV BATS_LIB_PATH=/bats/

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
RUN sed -i '/buffer_with_truncation /d' /bats/bats-core/libexec/bats-core/bats-format-pretty

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
