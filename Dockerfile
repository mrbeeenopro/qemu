FROM debian:bookworm-slim

RUN apt update && apt install -y \
    qemu-system-x86 \
    qemu-utils \
    qemu-efi-aarch64 \
    qemu-system-arm \
    iproute2 \
    net-tools \
    curl \
    ca-certificates \
    python3 \
    git \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/h3l2f/noVNC1 /opt/novnc \
    && cd /opt/novnc \
    && cp vnc.html index.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN useradd -m -d /home/container container
USER container

ENV USER=container HOME=/home/container
WORKDIR /home/container

CMD ["/bin/bash", "/entrypoint.sh"]
