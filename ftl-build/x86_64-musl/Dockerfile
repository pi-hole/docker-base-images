FROM alpine:3.12

# For FTL test compilation
ARG CIRCLE_JOB="x86_64-musl"
ARG CIRCLE_TAG="test-build"
ARG BRANCH="special/CI_development"

# ghr 0.13.0 2019-09-16
ARG ghrversion=0.13.0

ARG idnversion=1.36
ARG readlineversion=8.0
ARG termcapversion=1.3.1

RUN apk add --no-cache \
        alpine-sdk \
        bash \
        bind-tools \
        curl \
        gmp-dev \
        libcap \
        linux-headers \
        nettle-static \
        nettle-dev \
        openssh-client \
        shadow \
        sqlite \
        binutils \
        cmake

# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN curl -sSL https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
    tar --strip-components=1 -C /usr/bin/ -xz \
    ghr_v${ghrversion}_linux_amd64/ghr

ENV CC gcc
ENV STATIC true

RUN curl -sSL https://ftl.pi-hole.net/libraries/libidn-${idnversion}.tar.gz | tar -xz \
    && cd libidn-${idnversion} \
    && ./configure --host=armv7-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
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
    && ./configure --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

# Test compile FTL's development branch, the result is removed from the final container
# We accept errors in the test step to be able to update the arch_tests if a change is intended
RUN git clone https://github.com/pi-hole/FTL.git \
    && cd FTL \
    && git checkout "${BRANCH}" \
    && bash .circleci/build-CI.sh "${STATIC}" "${BRANCH}" "${CIRCLE_TAG}" "${CIRCLE_JOB}" \
    && bash test/arch_test.sh \
    && readelf -l ./pihole-FTL \
    && cd .. \
    && rm -r FTL
