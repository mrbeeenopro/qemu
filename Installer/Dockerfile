FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        openssl \
        aria2 \
        libguestfs-tools \
        guestfs-tools \
        qemu-utils \
        cloud-guest-utils \
        fdisk \
        gdisk \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /mnt/server
CMD ["/bin/bash"]
