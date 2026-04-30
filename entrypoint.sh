#!/bin/bash

# --- 1. Define ANSI Color Codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color


echo -e "${GREEN}[+] Initializing environment..."

cd /home/container

# Fix QEMU temp write
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
  0.0.0.0:${SERVER_PORT} \
  localhost:${VNC_PORT} > /dev/null 2>&1 &


sleep 2

cd /home/container
echo -e "${GREEN}[+] Entering QEMU Console. You can type your commands now!${NC}"

MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

eval exec ${MODIFIED_STARTUP}
