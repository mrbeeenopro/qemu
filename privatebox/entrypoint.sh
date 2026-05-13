#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' 

echo -e "${GREEN}[+] Initializing environment..."

cd /home/container
export TMPDIR=/home/container/tmp
mkdir -p $TMPDIR

VNC_PORT=5901

echo -e "${GREEN}[+] Network Configuration:${NC}"
echo -e " ↳ QEMU VNC : ${YELLOW}1 → 5901${NC}"
echo -e " ↳ noVNC Web: ${YELLOW}$SERVER_PORT${NC}"

echo -e "${GREEN}[+] Starting noVNC in the background...${NC}"
cd /opt/novnc

./utils/websockify/run \
  --web /opt/novnc \
  0.0.0.0:6080 \
  localhost:${VNC_PORT} > /dev/null 2>&1 &

# --- Khởi động Cloudflare Tunnel trực tiếp ---
echo -e "${CYAN}[+] Starting TryCloudflare Tunnel...${NC}"
rm -f /home/container/cloudflare.log

# Chạy tunnel trỏ vào port của noVNC
cloudflared tunnel --url http://127.0.0.1:6080 --no-autoupdate > /home/container/cloudflare.log 2>&1 &

# Vòng lặp chờ lấy URL (tối đa 30 giây)
echo -n -e "${YELLOW}[+] Waiting for Cloudflare URL...${NC}"
for i in {1..30}; do
    CF_URL=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' /home/container/cloudflare.log)
    if [ ! -z "$CF_URL" ]; then
        echo -e "\n${YELLOW}--------------------------------------------------${NC}"
        echo -e "${GREEN}Your Web Tunnel is live!${NC}"
        echo -e "${CYAN}URL: ${CF_URL}${NC}"
        echo -e "${YELLOW}--------------------------------------------------${NC}"
        break
    fi
    echo -n "."
    sleep 1
done
echo ""

# Tiếp tục các bước khởi động QEMU
sleep 1
cd /home/container
echo -e "${GREEN}[+] Entering QEMU Console. You can type your commands now!${NC}"

MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g} -e 's/}}/}/g')

eval exec "$MODIFIED_STARTUP"
