ARG readlineversion=8.3
ARG termcapversion=1.3.1-patched
ARG nettleversion=3.10.2
ARG mbedtlsversion=4.0.0
ARG opensslversion=3.5.7
ARG BATS_CORE_VER=v1.14.0
ARG BATS_SUPPORT_VER=v0.3.0
ARG BATS_ASSERT_VER=v2.2.4
ARG BATS_FILE_VER=v0.4.0

FROM alpine:3.24 AS base

# apk uses a BuildKit cache mount instead of --no-cache so downloaded packages are
# reused across builds rather than bloating the layer. Intentional tradeoff: without
# --no-cache the index is no longer force-refreshed each build, so package versions
# can go stale between cache-mount evictions. Acceptable for a build toolchain pinned
# to a specific alpine tag.
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

# Build static OpenSSL 3.5 LTS (TLS for civetweb + DoT/DoH, and native QUIC for
# the future DoQ/DoH3 work).
# Trimmed for binary size: drop the legacy provider, unused protocols/ciphers,
# engines and DSO. QUIC stays enabled (default in 3.5). no-deprecated is left
# off on purpose: it saves very little and would require a civetweb patch
# (SSL_library_init, SSL_get_peer_certificate) to keep compiling.
# Pick the OpenSSL target from TARGETPLATFORM: ./config guesses it from `uname`,
# which is wrong whenever the container arch differs from the build host kernel
# (386 on a 64-bit kernel, the 32-bit ARM variants on an arm64 runner, riscv64
# under QEMU) and yields "64-bit mode not compiled in". Runtime CPU-feature
# dispatch still handles AES-NI etc., so no further per-arch tuning is needed.
FROM base AS openssl-build
ARG TARGETPLATFORM
ARG opensslversion
RUN case "${TARGETPLATFORM}" in \
        "linux/amd64")   OSSL_TARGET="linux-x86_64"    ;; \
        "linux/386")     OSSL_TARGET="linux-x86"       ;; \
        "linux/arm/v6")  OSSL_TARGET="linux-armv4"     ;; \
        "linux/arm/v7")  OSSL_TARGET="linux-armv4"     ;; \
        "linux/arm64")   OSSL_TARGET="linux-aarch64"   ;; \
        "linux/riscv64") OSSL_TARGET="linux64-riscv64" ;; \
        *) echo "unsupported TARGETPLATFORM: ${TARGETPLATFORM}" >&2; exit 1 ;; \
    esac \
    && curl -sSL https://ftl.pi-hole.net/libraries/openssl-${opensslversion}.tar.gz | tar -xz \
    && cd openssl-${opensslversion} \
    && ./Configure "${OSSL_TARGET}" \
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
FROM base AS libbacktrace-build
RUN git clone https://github.com/ianlancetaylor/libbacktrace.git \
    && cd libbacktrace \
    && ./configure --enable-static --disable-shared \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libbacktrace

# Install bats-core, plus the bats-support/bats-assert/bats-file helper
# libraries FTL's test suite loads via BATS_LIB_PATH
FROM base AS bats-build
ARG BATS_CORE_VER
ARG BATS_SUPPORT_VER
ARG BATS_ASSERT_VER
ARG BATS_FILE_VER
RUN git clone --depth=1 --single-branch --branch "${BATS_CORE_VER}" https://github.com/bats-core/bats-core.git /bats/bats-core \
  && git clone --depth=1 --single-branch --branch "${BATS_SUPPORT_VER}" https://github.com/bats-core/bats-support /bats/bats-support \
  && git clone --depth=1 --single-branch --branch "${BATS_ASSERT_VER}" https://github.com/bats-core/bats-assert  /bats/bats-assert \
  && git clone --depth=1 --single-branch --branch "${BATS_FILE_VER}" https://github.com/bats-core/bats-file    /bats/bats-file

FROM base AS build

ENV STATIC=true
ENV TEST=true

COPY --link --from=termcap-build /usr/local/ /usr/local/
COPY --link --from=readline-build /usr/local/ /usr/local/
COPY --link --from=nettle-build /usr/local/ /usr/local/
COPY --link --from=mbedtls-build /usr/local/ /usr/local/
COPY --link --from=openssl-build /usr/local/ /usr/local/
COPY --link --from=libbacktrace-build /usr/local/ /usr/local/
COPY --link --from=bats-build /bats /bats

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

# Test compile FTL's development branch, the result is removed from the final container
# Run the full test suite to ensure that the container is still capable of running the tests
# Ensure that the TERM environment variable is set for BATS color output
RUN git clone https://github.com/pi-hole/FTL.git --branch "${GIT_BRANCH}" \
    && cd FTL \
    && bash build.sh "-DSTATIC=${STATIC} -DBUILD_TAR_REGRESSION=ON -DBUILD_GZIP_REGRESSION=ON -DBUILD_DOTDOH_REGRESSION=ON" \
    && readelf -A ./pihole-FTL \
    && readelf -l ./pihole-FTL \
    && bash test/arch_test.sh \
    && TERM=${TERM:-xterm} bash test/run.sh \
    && cd .. \
    && rm -r FTL
