FROM debian:stretch

# For FTL test compilation
ARG CI_ARCH="armv8a"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

ARG idnversion=1.41
ARG readlineversion=8.1
ARG termcapversion=1.3.1

RUN dpkg --add-architecture armhf \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        gcc-arm-linux-gnueabihf \
        libc6-dev-armhf-cross \
        libcap-dev:armhf \
        libcap2-bin \
        make \
        netcat-traditional \
        nettle-dev:armhf \
        ssh \
        sqlite3 \
        wget \
        binutils \
        cmake \
        libc6:armhf \
        xxd \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Github actions/Checkout@v2 requires git >=2.18 else it will fall back to github API to download tarball
# stretch-backports also has dnsutils 9.11.5, which has support for +unknown (See https://github.com/pi-hole/FTL/pull/1223#discussion_r731148277)
RUN echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get -t stretch-backports install --no-install-recommends -y \
        git \
        dnsutils

ENV CC "arm-linux-gnueabihf-gcc -march=armv8-a -isystem /usr/local/include"
RUN ln -s /usr/arm-linux-gnueabihf/lib/libm.so /usr/local/lib/

RUN curl -sSL https://ftl.pi-hole.net/libraries/libidn-${idnversion}.tar.gz | tar -xz \
    && cd libidn-${idnversion} \
    && ./configure --host=armv8-linux-gnueabi --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libidn-${idnversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --host=armv8-linux-gnueabihf --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --host=armv8-linux-gnueabihf --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

# Test compile FTL's development branch, the result is removed from the final container
# We accept errors in the test step to be able to update the arch_tests if a change is intended
RUN git clone https://github.com/pi-hole/FTL.git \
    && cd FTL \
    && git checkout "${GIT_BRANCH}" \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && bash test/arch_test.sh \
    && cd .. \
    && rm -r FTL
