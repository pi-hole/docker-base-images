ARG ALPINE_VER=3.18
FROM alpine:${ALPINE_VER} AS builder

ARG idnversion=1.41
ARG readlineversion=8.1
ARG termcapversion=1.3.1
ARG nettleversion=3.8.1
ARG mbedtlsversion=3.4.0

RUN apk add --no-cache \
        alpine-sdk \
        bash \
        bind-tools \
        curl \
        gmp-dev \
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
        perl

# Install pdns from community repo
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VER}/community" >> /etc/apk/repositories; \
    apk update; \
    apk add --no-cache \
    pdns \
    pdns-backend-sqlite3 \
    pdns-recursor \
    pdns-doc

ENV CC gcc
ENV STATIC true

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

RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --enable-static --disable-shared \
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

# Install bats-core directly into the build image
RUN git clone https://github.com/bats-core/bats-core.git \
    && cd bats-core

ENV BATS=/bats-core/bin/bats

FROM builder AS tester

# For FTL test compilation
ARG CI_ARCH="x86_64-musl"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

# Test compile FTL's development branch, the result is removed from the final container
# We accept errors in the arwch_test step to be able to update the arch_tests if a change is intended
# Run the full test suite to ensure that the container is still capable of running the tests
RUN git clone https://github.com/pi-hole/FTL.git \
    && cd FTL \
    && git checkout "${GIT_BRANCH}" \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && bash test/arch_test.sh \
    && bash test/run.sh \
    && readelf -l ./pihole-FTL \
    && cd .. \
    && rm -r FTL
