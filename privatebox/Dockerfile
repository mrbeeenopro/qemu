FROM debian:bookworm-slim

RUN apt update && apt install -y \
    qemu-system-x86 \
    qemu-utils \
    iproute2 \
    net-tools \
    curl \
    ca-certificates \
    python3 \
    git \
    telnet \
    python3-numpy \
    wget \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then CF_ARCH="amd64"; \
    elif [ "$ARCH" = "arm64" ]; then CF_ARCH="arm64"; \
    elif [ "$ARCH" = "armhf" ]; then CF_ARCH="arm"; \
    else CF_ARCH="amd64"; fi && \
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$CF_ARCH -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

RUN git clone https://github.com/h3l2f/noVNC1 /opt/novnc \
    && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify \
    && cd /opt/novnc \
    && cp vnc.html index.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

RUN useradd -m -d /home/container container
USER container

WORKDIR /home/container
CMD ["/bin/bash", "/entrypoint.sh"]
