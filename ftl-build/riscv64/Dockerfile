FROM debian:sid AS builder

ARG idnversion=1.41
ARG readlineversion=8.1
ARG termcapversion=1.3.1
ARG nettleversion=3.8.1

RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates debian-ports-archive-keyring \
    && echo 'deb [arch=riscv64] https://deb.debian.org/debian-ports sid main' > /etc/apt/sources.list.d/riscv64.list \
    && dpkg --add-architecture riscv64 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        file \
        build-essential \
        gcc-riscv64-linux-gnu \
        libc6-dev-riscv64-cross \
        libcap-dev:riscv64 \
        libcap2-bin \
        make \
        netcat-traditional \
        m4 \
        libgmp-dev:riscv64 \
        ssh \
        sqlite3 \
        wget \
        binutils \
        cmake \
        libc6-dev:riscv64 \
        xxd \
        jq \
        git \
        dnsutils \
    && rm -rf /var/lib/apt/lists/*

ENV CC riscv64-linux-gnu-gcc -isystem /usr/local/include

RUN curl -sSL https://ftl.pi-hole.net/libraries/libidn-${idnversion}.tar.gz | tar -xz \
    && cd libidn-${idnversion} \
    && ./configure --host=riscv64-linux-gnu --enable-static --disable-shared --disable-doc --disable-valgrind-tests \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r libidn-${idnversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/termcap-${termcapversion}.tar.gz | tar -xz \
    && cd termcap-${termcapversion} \
    && ./configure --host=riscv64-linux-gnu --enable-static --disable-shared --disable-doc --without-examples \
    && make -j $(nproc) \
    && make install \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r termcap-${termcapversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/readline-${readlineversion}.tar.gz | tar -xz \
    && cd readline-${readlineversion} \
    && ./configure --host=riscv64-linux-gnu --enable-static --disable-shared --disable-install-examples \
    && make -j $(nproc) \
    && make install-static \
    && ls /usr/local/lib/ \
    && cd .. \
    && rm -r readline-${readlineversion}

RUN curl -sSL https://ftl.pi-hole.net/libraries/nettle-${nettleversion}.tar.gz | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure --host=riscv64-linux-gnu --enable-static --disable-shared --disable-documentation \
    && make -j $(nproc) install \
    && cd .. \
    && rm -r nettle-${nettleversion}

FROM builder AS tester

# For FTL test compilation
ARG CI_ARCH="riscv64"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

# Test compile FTL's development branch, the result is removed from the final container
# We accept errors in the test step to be able to update the arch_tests if a change is intended
RUN git clone https://github.com/pi-hole/FTL.git \
    && cd FTL \
    && git checkout "${GIT_BRANCH}" \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && bash test/arch_test.sh \
    && cd .. \
    && rm -r FTL
