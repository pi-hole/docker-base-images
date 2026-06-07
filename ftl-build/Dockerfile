ARG readlineversion=8.3
ARG termcapversion=1.3.1-patched
ARG nettleversion=3.10.2
ARG mbedtlsversion=4.0.0
# lastet master commit
ARG libbacktraceversion=96664e69b1ecdb76e824be1d9e8f475b76dd08cf
# unreleased changes post v1.13.0
ARG batsversion=d9faff0d7bc32e7adebc6552446f978118d3ab3b

FROM alpine:3.23 AS base

RUN --mount=type=cache,target=/var/cache/apk \
    apk add \
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

# As of Alpine 3.21 (Dec 2024), we need to patch the termcap library to include
# the standard headers as well as unistd.h for the write function
FROM base AS termcap-build
ARG termcapversion
RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --enable-static --disable-shared --disable-doc --without-examples \
    && sed -i '1i #define STDC_HEADERS 1\n#include <unistd.h>' termcap.c tparam.c \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

FROM base AS readline-build
ARG readlineversion
COPY --from=termcap-build /usr/local/ /usr/local/
RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --enable-static --disable-shared --disable-install-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

FROM base AS nettle-build
ARG nettleversion
RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --enable-static --disable-shared --disable-openssl --disable-mini-gmp -disable-gcov --disable-documentation \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r nettle-${nettleversion}

# Build static mbedTLS with pthread support
# Disable AESNI on linux/386 asit would possibly result in an incompatible
# binary in processors lacking the AESNI and SSE2 instruction sets
FROM base AS mbedtls-build
ARG TARGETPLATFORM
ARG mbedtlsversion
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

# Build static libbacktrace
FROM base AS libbacktrace-build
ARG libbacktraceversion
RUN curl -sSL https://github.com/ianlancetaylor/libbacktrace/archive/${libbacktraceversion}.tar.gz | tar -xz \
    && cd libbacktrace-${libbacktraceversion} \
    && ./configure --enable-static --disable-shared \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libbacktrace-${libbacktraceversion}

# Install bats-core directly into the build image
FROM base AS bats-build
ARG batsversion
RUN curl -sSL https://github.com/bats-core/bats-core/archive/${batsversion}.tar.gz | tar -xz \
    && mv bats-core-${batsversion} bats-core

FROM base AS build

ENV STATIC=true
ENV TEST=true

COPY --link --from=termcap-build /usr/local/ /usr/local/
COPY --link --from=readline-build /usr/local/ /usr/local/
COPY --link --from=nettle-build /usr/local/ /usr/local/
COPY --link --from=mbedtls-build /usr/local/ /usr/local/
COPY --link --from=libbacktrace-build /usr/local/ /usr/local/
COPY --link --from=bats-build /bats-core /bats-core

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
