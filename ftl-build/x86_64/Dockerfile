FROM debian:stretch

# For FTL test compilation
ARG CI_ARCH="x86_64"
ARG GIT_TAG="test-build"
ARG GIT_BRANCH="special/CI_development"

ARG idnversion=1.36
ARG readlineversion=8.0
ARG termcapversion=1.3.1

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        gcc \
        libcap2-bin \
        libcap-dev \
        libc-dev \
        make \
        netcat-traditional \
        nettle-dev \
        sqlite3 \
        ssh \
        wget \
        binutils \
        cmake \
        xxd \
        jq \
        gnupg \
        psmisc \
    && rm -rf /var/lib/apt/lists/*

# Pin powerdns repo in APT to get pdns-recursor
RUN echo "deb [arch=amd64] http://repo.powerdns.com/debian stretch-auth-44 main" >> /etc/apt/sources.list.d/pdns.list; \
    echo "Package: pdns-*" > /etc/apt/preferences.d/pdns; \
    echo "Pin: origin repo.powerdns.com" >> /etc/apt/preferences.d/pdns; \
    echo "Pin-Priority: 600" >> /etc/apt/preferences.d/pdns; \
    curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - ; \
    apt-get update; \
    apt-get install pdns-server -y;

# Pin powerdns repo in APT to get pdns-recursor
RUN echo "deb [arch=amd64] http://repo.powerdns.com/debian stretch-rec-44 main" >> /etc/apt/sources.list.d/pdns.list; \
    echo "Package: pdns-*" > /etc/apt/preferences.d/pdns; \
    echo "Pin: origin repo.powerdns.com" >> /etc/apt/preferences.d/pdns; \
    echo "Pin-Priority: 600" >> /etc/apt/preferences.d/pdns; \
    curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - ; \
    apt-get update; \
    apt-get install pdns-recursor -y;

# Wget the pdns-backend-sqlite3.deb and install it
RUN wget https://repo.powerdns.com/debian/pool/main/p/pdns/pdns-backend-sqlite3_4.4.1-1pdns.stretch_amd64.deb; \
    dpkg -i pdns-backend-sqlite3_4.4.1-1pdns.stretch_amd64.deb

# Github actions/Checkout@v2 requires git >=2.18 else it will fall back to github API to download tarball
# stretch-backports also has dnsutils 9.11.5, which has support for +unknown (See https://github.com/pi-hole/FTL/pull/1223#discussion_r731148277)
RUN echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get -t stretch-backports install --no-install-recommends -y \
        git \
        dnsutils

ENV CC gcc

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

# Install bats-core directly into the build image
RUN git clone https://github.com/bats-core/bats-core.git \
    && cd bats-core

ENV BATS=/bats-core/bin/bats

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
