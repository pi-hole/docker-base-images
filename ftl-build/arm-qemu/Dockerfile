FROM multiarch/debian-debootstrap:armel-stretch-slim

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    curl \
    dnsutils \
    git \
    libcap2-bin \
    libgmp-dev \
    m4 \
&& rm -rf /var/lib/apt/lists/*

RUN curl https://ftp.gnu.org/gnu/nettle/nettle-3.4.tar.gz  | tar -xz \
&& cd nettle-3.4 \
&& ./configure \
&& make \
&& make install \
&& cd .. \
&& rm -r nettle-3.4
