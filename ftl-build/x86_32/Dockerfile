FROM debian:buster AS builder

ARG idnversion=1.41
ARG readlineversion=8.1
ARG termcapversion=1.3.1
ARG nettleversion=3.9
ARG mbedtlsversion=3.4.0

# We need a more recent dnsutils version for native HTTPS and SVCB support in dig
RUN dpkg --add-architecture i386 \
    && echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        gcc \
        gcc-multilib \
        libcap2-bin \
        libcap-dev:i386 \
        make \
        netcat-traditional \
        m4 \
        libgmp-dev:i386 \
        sqlite3 \
        ssh \
        wget \
        binutils \
        cmake \
        libc6:i386 \
        xxd \
        jq \
        gnupg \
        psmisc \
        git \
        python3 \
        python3-yaml \
        python3-requests \
        zip \
        perl \
    && apt-get -t buster-backports install --no-install-recommends -y \
        dnsutils \
    && rm -rf /var/lib/apt/lists/*

# Pin powerdns repo in APT to get pdns-recursor
RUN echo "deb [arch=amd64] http://repo.powerdns.com/debian buster-auth-46 main" >> /etc/apt/sources.list.d/pdns.list && \
    echo "Package: pdns-*" > /etc/apt/preferences.d/pdns && \
    echo "Pin: origin repo.powerdns.com" >> /etc/apt/preferences.d/pdns && \
    echo "Pin-Priority: 600" >> /etc/apt/preferences.d/pdns && \
    curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - && \
    apt-get update && \
    apt-get install pdns-server pdns-recursor -y

# Wget the pdns-backend-sqlite3.deb and install it
RUN wget https://repo.powerdns.com/debian/pool/main/p/pdns/pdns-backend-sqlite3_4.6.4-1pdns.buster_amd64.deb; \
    dpkg -i pdns-backend-sqlite3_4.6.4-1pdns.buster_amd64.deb && \
    rm pdns-backend-sqlite3_4.6.4-1pdns.buster_amd64.deb

ENV CC "gcc -m32"
RUN ln -s /usr/lib32/libm.so /usr/local/lib/

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
    && ./configure --enable-static --disable-shared --disable-documentation \
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
ARG CI_ARCH="x86_32"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

# Test compile FTL's development branch, the result is removed from the final container
# We accept errors in the arch_test step to be able to update the arch_tests if a change is intended
# Run the full test suite to ensure that the container is still capable of running the tests
RUN git clone https://github.com/pi-hole/FTL.git \
    && cd FTL \
    && git checkout "${GIT_BRANCH}" \
    && bash build.sh "-DSTATIC=${STATIC}" \
    && bash test/arch_test.sh \
    && bash test/run.sh \
    && cd .. \
    && rm -r FTL
