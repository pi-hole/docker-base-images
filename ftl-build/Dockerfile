ARG CONTAINER="alpine:3.21"

ARG TARGETPLATFORM

FROM ${CONTAINER} AS termcap-builder

ARG termcapversion=1.3.1

RUN apk add --update --no-cache \
    curl \
    gcc \
    make \
    musl-dev
# As of Alpine 3.21 (Dec 2024), we need to patch the termcap library to include
# the standard headers as well as unistd.h for the write function
RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --enable-static --disable-shared --disable-doc --without-examples \
    && sed -i '1i #define STDC_HEADERS 1\n#include <unistd.h>' termcap.c tparam.c \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ 

FROM ${CONTAINER} AS readline-builder

ARG readlineversion=8.2

RUN apk add --update --no-cache \
    curl \
    gcc \
    g++ \
    make

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --enable-static --disable-shared --disable-install-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/

FROM ${CONTAINER} AS nettle-builder

ARG nettleversion=3.10.1

RUN apk add --update --no-cache \
    curl \
    gmp-dev \
    g++ \
    make \
    m4
    
RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --enable-static --disable-shared --disable-openssl --disable-mini-gmp -disable-gcov --disable-documentation \
    && make -j $(nproc) install \
    && ls /usr/local/lib

FROM ${CONTAINER} AS mbedtls-builder

ARG mbedtlsversion=3.6.2

RUN apk add --update --no-cache \
    curl \
    g++ \
    make \
    musl-dev \
    python3

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
    && ls /usr/local/lib

FROM ${CONTAINER} AS libbacktrace-builder

RUN apk add --update --no-cache \
    g++ \
    git \
    make

# Build static libbacktrace
RUN git clone https://github.com/ianlancetaylor/libbacktrace.git \
    && cd libbacktrace \
    && ./configure --enable-static --disable-shared \
    && make -j $(nproc) install \
    && ls /usr/local/lib

FROM ${CONTAINER} AS ftl-builder

RUN apk add --update --no-cache \
        alpine-sdk \
        bash \
        bind-tools \
        binutils \
        clang \
        cmake \
        curl \
        gdb \
        gmp-dev \
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
        py3-jinja2 \
        py3-jsonschema \
        py3-requests \
        py3-yaml \
        python3 \
        shadow \
        sqlite \
        xxd \
        zip 

ENV STATIC=true
ENV TEST=true

# Install bats-core directly into the build image
RUN git clone https://github.com/bats-core/bats-core.git

ENV BATS=/bats-core/bin/bats

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

COPY --from=termcap-builder /usr/local/lib/lib* /usr/local/lib/
COPY --from=readline-builder /usr/local/lib/lib* /usr/local/lib/
COPY --from=readline-builder /usr/local/include/readline/ /usr/local/include/readline/
COPY --from=nettle-builder /usr/local/lib/lib* /usr/local/lib/
COPY --from=nettle-builder /usr/local/include/nettle/ /usr/local/include/nettle/
COPY --from=mbedtls-builder /usr/local/lib/lib* /usr/local/lib/
COPY --from=mbedtls-builder /usr/local/include/mbedtls/ /usr/local/include/mbedtls/ 
COPY --from=mbedtls-builder /usr/local/include/psa/ /usr/local/include/psa/ 
COPY --from=libbacktrace-builder /usr/local/lib/lib* /usr/local/lib/

# Test compile FTL's development branch, the result is removed from the final container
# Run the full test suite to ensure that the container is still capable of running the tests
RUN git clone https://github.com/pi-hole/FTL.git --branch "${GIT_BRANCH}" \
    && cd FTL \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && readelf -A ./pihole-FTL \
    && readelf -l ./pihole-FTL \
    && bash test/arch_test.sh \
    && bash test/run.sh
