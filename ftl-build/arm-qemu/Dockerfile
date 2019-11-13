FROM multiarch/debian-debootstrap:armel-stretch-slim

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    dnsutils \
    git \
    libcap2-bin \
    libgmp-dev \
    m4 \
&& rm -rf /var/lib/apt/lists/*
RUN wget https://ftp.gnu.org/gnu/nettle/nettle-3.4.tar.gz && tar -xzf nettle-3.4.tar.gz && cd nettle-3.4 && ./configure && \
    make && make install
