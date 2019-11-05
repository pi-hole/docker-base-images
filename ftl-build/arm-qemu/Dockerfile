FROM multiarch/debian-debootstrap:armel-stretch-slim

RUN apt-get update && apt-get install --no-install-recommends -y build-essential libcap2-bin libgmp-dev m4 ca-certificates dnsutils
RUN wget https://ftp.gnu.org/gnu/nettle/nettle-3.4.tar.gz && tar -xzf nettle-3.4.tar.gz && cd nettle-3.4 && ./configure && \
    make && make install
