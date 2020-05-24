FROM multiarch/debian-debootstrap:armel-stretch-slim

ARG nettleversion=3.4

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        dnsutils \
        git \
        libcap2-bin \
        libgmp-dev \
        libidn11-dev \
        m4 \
        binutils \
        cmake \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://ftp.gnu.org/gnu/nettle/nettle-${nettleversion}.tar.gz  | tar -xz \
    && cd nettle-${nettleversion} \
    && ./configure \
    && make -j $(nproc) \
    && make install \
    && cd .. \
    && rm -r nettle-${nettleversion}
