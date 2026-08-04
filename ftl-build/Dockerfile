# syntax=docker/dockerfile:1
ARG readlineversion=8.3
ARG termcapversion=1.3.1-patched
ARG nettleversion=3.10.2
ARG opensslversion=4.0.0
ARG nghttp2version=1.69.0
ARG nghttp3version=1.17.0
ARG ngtcp2version=1.24.0
ARG BATS_CORE_VER=v1.14.0
ARG BATS_SUPPORT_VER=v0.3.0
ARG BATS_ASSERT_VER=v2.2.4
ARG BATS_FILE_VER=v0.4.0

FROM alpine:3.24 AS base

RUN apk add --no-cache \
        alpine-sdk \
        bash \
        bind-tools \
        binutils \
        ccache \
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
        py3-aioquic \
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

# Build every bundled static library with per-function/data sections so FTL
# can drop unreferenced code at link time with -Wl,--gc-sections. Set on `base`
# so every per-library stage inherits it.
ENV SECTION_FLAGS="-ffunction-sections -fdata-sections"

# As of Alpine 3.21 (Dec 2024), we need to patch the termcap library to include
# the standard headers as well as unistd.h for the write function
FROM base AS termcap-build
ARG termcapversion
RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && CFLAGS="-O2 ${SECTION_FLAGS}" ./configure --enable-static --disable-shared --disable-doc --without-examples \
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
    && CFLAGS="-O2 ${SECTION_FLAGS}" ./configure --enable-static --disable-shared --disable-install-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

FROM base AS nettle-build
ARG nettleversion
RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && CFLAGS="-O2 ${SECTION_FLAGS}" ./configure --enable-static --disable-shared --disable-openssl --disable-mini-gmp -disable-gcov --disable-documentation \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r nettle-${nettleversion}

# Build static OpenSSL 4.0 (TLS for civetweb + DoT/DoH, and native QUIC plus the
# SSL_get_peer_addr API the future DoQ/DoH3 work needs).
# Trimmed for binary size: drop the legacy provider, unused protocols/ciphers
# and DSO. QUIC stays enabled (default since 3.5). no-deprecated is left off on
# purpose: it saves very little and would require a civetweb patch
# (SSL_library_init, SSL_get_peer_certificate) to keep compiling. no-ssl3 /
# no-engine are not passed: SSLv3 and the ENGINE API are already gone in 4.0, so
# both are only accepted as deprecated Configure options.
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
        no-legacy no-comp no-dtls \
        no-psk no-srp no-idea no-rc2 no-rc4 no-rc5 no-md4 no-mdc2 no-whirlpool \
        no-dso \
        ${SECTION_FLAGS} \
        --prefix=/usr/local --libdir=lib --openssldir=/usr/local/ssl \
    && make -j $(nproc) \
    && make install_dev \
    && ls -l /usr/local/lib/libssl.a /usr/local/lib/libcrypto.a \
    && cd .. \
    && rm -r openssl-${opensslversion}

# Static HTTP/2, HTTP/3 and QUIC libraries. Library-only builds
# (--enable-lib-only) to drop the apps and their extra dependencies.
FROM base AS nghttp2-build
ARG nghttp2version
RUN curl -sSL https://ftl.pi-hole.net/libraries/nghttp2-${nghttp2version}.tar.gz | tar -xz \
    && cd nghttp2-${nghttp2version} \
    && CFLAGS="-O2 ${SECTION_FLAGS}" ./configure --enable-lib-only --enable-static --disable-shared \
    && make -j $(nproc) install \
    && ls -l /usr/local/lib/libnghttp2.a \
    && cd .. \
    && rm -r nghttp2-${nghttp2version}

FROM base AS nghttp3-build
ARG nghttp3version
RUN curl -sSL https://ftl.pi-hole.net/libraries/nghttp3-${nghttp3version}.tar.gz | tar -xz \
    && cd nghttp3-${nghttp3version} \
    && CFLAGS="-O2 ${SECTION_FLAGS}" ./configure --enable-lib-only --enable-static --disable-shared \
    && make -j $(nproc) install \
    && ls -l /usr/local/lib/libnghttp3.a \
    && cd .. \
    && rm -r nghttp3-${nghttp3version}

# ngtcp2 needs OpenSSL: --with-openssl builds the "ossl" crypto backend
# (libngtcp2_crypto_ossl) against the static OpenSSL 4.0 above. nghttp3 is copied
# in as well: it is not needed for --enable-lib-only, but it was present when
# these three shared a single stage, so it is kept in scope to keep configure's
# probe results - and therefore the installed artefacts - identical.
FROM base AS ngtcp2-build
ARG ngtcp2version
COPY --from=openssl-build /usr/local/ /usr/local/
COPY --from=nghttp3-build /usr/local/ /usr/local/
RUN curl -sSL https://ftl.pi-hole.net/libraries/ngtcp2-${ngtcp2version}.tar.gz | tar -xz \
    && cd ngtcp2-${ngtcp2version} \
    && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig CFLAGS="-O2 ${SECTION_FLAGS}" ./configure --enable-lib-only --enable-static --disable-shared --with-openssl \
    && make -j $(nproc) install \
    && ls -l /usr/local/lib/libngtcp2.a /usr/local/lib/libngtcp2_crypto_ossl.a \
    && cd .. \
    && rm -r ngtcp2-${ngtcp2version}

# Build static libbacktrace
FROM base AS libbacktrace-build
RUN git clone https://github.com/ianlancetaylor/libbacktrace.git \
    && cd libbacktrace \
    && CFLAGS="-O2 ${SECTION_FLAGS}" ./configure --enable-static --disable-shared \
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

# The collector stage gathers the static libraries and headers from the build stages above
# This allows for a single COPY command in the build stage and reduces the number of layers in the final image.
FROM scratch AS collector

COPY --link --parents --from=termcap-build /usr/local/lib /usr/local/include /
COPY --link --parents --from=readline-build /usr/local/lib /usr/local/include /
COPY --link --parents --from=nettle-build /usr/local/lib /usr/local/include /
COPY --link --parents --from=openssl-build /usr/local/lib /usr/local/include /
COPY --link --parents --from=nghttp2-build /usr/local/lib /usr/local/include /
COPY --link --parents --from=nghttp3-build /usr/local/lib /usr/local/include /
COPY --link --parents --from=ngtcp2-build /usr/local/lib /usr/local/include /
COPY --link --parents --from=libbacktrace-build /usr/local/lib /usr/local/include /

FROM base AS build

ENV STATIC=true
ENV TEST=true

COPY --link --parents --from=collector /usr/local/lib /usr/local/include /
COPY --link --from=bats-build /bats /bats

ENV BATS=/bats/bats-core/bin/bats
ENV BATS_LIB_PATH=/bats/

# Verify the static libraries are present and correct. This uses a POSIX shell
# loop so it works with Alpine's default /bin/sh (no brace expansion).
RUN for lib in termcap readline history nettle hogweed ssl crypto nghttp2 nghttp3 ngtcp2 ngtcp2_crypto_ossl backtrace; do \
        [ -f "/usr/local/lib/lib${lib}.a" ] || { echo "missing lib${lib}.a" >&2; exit 1; }; \
    done

# Both FTL compiles below - the ccache seed and the validation run - have to
# invoke the compiler identically or ccache never hits, so everything they share
# is defined here and neither stage can drift away from it.
FROM build AS ftl-validate
ENV CCACHE_DIR=/ccache
ENV CCACHE_MAXSIZE=500M
ENV FTL_CMAKE_ARGS="-DSTATIC=${STATIC} -DBUILD_TAR_REGRESSION=ON -DBUILD_GZIP_REGRESSION=ON -DBUILD_DOTDOH_REGRESSION=ON -DCMAKE_C_COMPILER_LAUNCHER=ccache"

# Compiling FTL is what the validation below actually costs, and most of it is
# spent on translation units FTL never touches: sqlite3.c alone is the critical
# path on every platform (~15 min of a ~29 min riscv64 build under QEMU). This
# stage compiles FTL once so the validation run can reuse the objects.
#
# It is deliberately not fed CACHEBUST, and nothing else expires it either: the
# layer should be served from the layer cache for as long as it survives there.
# That cannot mask a toolchain regression, because this stage sits on top of
# every toolchain layer - a new alpine digest, a different package set or a
# rebuilt library invalidates it and forces a fresh compile. It does go stale
# against FTL, which is harmless: changed sources miss and are compiled, and an
# unchanged source cannot yield a different object from an unchanged compiler.
#
# Only /ccache survives; the checkout is dropped so the exported layer stays
# small (~28 MB), as the GHA cache is a shared, size-limited resource.
FROM ftl-validate AS ccache-seed
ARG GIT_BRANCH="special/CI_development"
RUN git clone https://github.com/pi-hole/FTL.git --branch "${GIT_BRANCH}" --single-branch \
    && cd FTL \
    && bash build.sh "${FTL_CMAKE_ARGS}" \
    && cd .. \
    && rm -rf FTL \
    && ccache --show-stats \
    && ccache --zero-stats

FROM ftl-validate AS test

# For FTL test compilation
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
ARG TARGETARCH
ARG TARGETVARIANT
ARG CI_ARCH="$TARGETPLATFORM"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

# Compile FTL's development branch and run the full test suite, to prove the
# toolchain can still build and test FTL. Nothing here is kept - this stage is a
# gate, not an artifact - so the checkout and everything run.sh writes outside it
# (/etc/pihole, /var/log/pihole, /etc/dnsmasq.d, /var/lib/powerdns, the pihole
# user, ...) is simply left in place and discarded with the stage.
#
# Build this target directly to debug a failure locally: the FTL tree and all
# logs survive for inspection.
#
# CACHEBUST is fed a per-run value so this layer never comes from cache - it must
# re-validate against current FTL every time, and a cache hit here would silently
# skip building and testing FTL entirely. On CI this is set automaically.
# For local builds, set `--build-arg CACHEBUST=$(date +%s)` to force a rebuild and test run.
#
# TERM is set for BATS colour output during the test run.
#
# The seeded ccache only ever short-circuits compiling a translation unit that
# is bit-identical to one already compiled with the same compiler and flags.
# Everything else - the link, the checksum, arch_test.sh and the full test suite
# - still runs from scratch on every build.
COPY --from=ccache-seed /ccache /ccache
ARG CACHEBUST=local
RUN echo "Validating toolchain against FTL (build ${CACHEBUST})" \
    && git clone https://github.com/pi-hole/FTL.git --branch "${GIT_BRANCH}" \
    && cd FTL \
    && bash build.sh "${FTL_CMAKE_ARGS}" \
    && ccache --show-stats \
    && readelf -A ./pihole-FTL \
    && readelf -l ./pihole-FTL \
    && bash test/arch_test.sh \
    && TERM=${TERM:-xterm} bash test/run.sh \
    && cd .. \
    && echo "${CACHEBUST}" > /toolchain-validated

# The published image: the toolchain exactly as `build` produced it, with none of
# the state the test run leaves behind.
#
# Dockerfiles have no way to say "this stage depends on that one", so the COPY is
# what pulls `test` into the build graph - without it BuildKit would see an
# orphaned stage, never run it, and happily publish an untested toolchain. Since
# the copy needs test's filesystem to resolve, and test's CACHEBUST layer can
# never be served from cache, FTL is rebuilt and retested on every build and a
# failure there fails this target before it exists.
#
# /toolchain-validated holds the CACHEBUST value, so the image also records which
# CI run validated it.
FROM build AS publish
COPY --from=test /toolchain-validated /toolchain-validated
