FROM debian:stretch

# For FTL test compilation
ARG CIRCLE_JOB="aarch64"
ARG CIRCLE_TAG="test-build"
ARG BRANCH="special/CI_development"

# ghr 0.13.0 2019-09-16
ARG ghrversion=0.13.0

ARG readlineversion=8.0
ARG termcapversion=1.3.1

RUN dpkg --add-architecture arm64 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        dnsutils \
        file \
        gcc-aarch64-linux-gnu \
        git \
        libc-dev-arm64-cross \
        libcap-dev:arm64 \
        libcap2-bin \
        libidn11-dev:arm64 \
        make \
        netcat-traditional \
        nettle-dev:arm64 \
        ssh \
        sqlite3 \
        wget \
        binutils \
        cmake \
        libc6-dev:arm64 \
    && rm -rf /var/lib/apt/lists/*

# Install ghr for GitHub Releases: https://github.com/tcnksm/ghr
RUN curl -sSL https://github.com/tcnksm/ghr/releases/download/v${ghrversion}/ghr_v${ghrversion}_linux_amd64.tar.gz | \
    tar --strip-components=1 -C /usr/bin/ -xz \
    ghr_v${ghrversion}_linux_amd64/ghr

ENV CC aarch64-linux-gnu-gcc -isystem /usr/local/include

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
    && ./configure --host=aarch64-linux-gnu --enable-static --disable-shared --disable-doc --without-examples \
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
    && bash .circleci/build-CI.sh "-DSTATIC=${STATIC}" "${BRANCH}" "${CIRCLE_TAG}" "${CIRCLE_JOB}" \
    && bash test/arch_test.sh \
    && cd .. \
    && rm -r FTL
