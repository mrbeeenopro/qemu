#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' 
USE_CLOUDFLARE=true
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
  localhost:6080 \
  localhost:${VNC_PORT} > /dev/null 2>&1 &

if [ "$USE_CLOUDFLARE" = "true" ]; then
    echo -e "${CYAN}[+] Starting TryCloudflare Tunnel...${NC}"
    cloudflared tunnel --url http://localhost:6080 --no-autoupdate > /home/container/cloudflare.log 2>&1 &
    
    sleep 5
    CF_URL=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' /home/container/cloudflare.log)
    echo -e "${YELLOW}--------------------------------------------------${NC}"
    echo -e "${GREEN}your web Tunnel is live!${NC}"
    echo -e "${CYAN}URL: ${CF_URL}${NC}"
    echo -e "${YELLOW}--------------------------------------------------${NC}"
fi

sleep 2
cd /home/container
echo -e "${GREEN}[+] Entering QEMU Console. You can type your commands now!${NC}"
export FORWARD_PORTS="${FORWARD_PORTS//\$\{SERVER_PORT\}/$SERVER_PORT}"
export FORWARD_PORTS="${FORWARD_PORTS//\$SERVER_PORT/$SERVER_PORT}"
MODIFIED_STARTUP="${STARTUP//\{\{SERVER_PORT\}\}/$SERVER_PORT}"
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

eval exec ${MODIFIED_STARTUP}
