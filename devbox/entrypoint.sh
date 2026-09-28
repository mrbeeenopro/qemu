#!/bin/bash

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

echo -e "${GREEN}[+] Starting noVNC...${NC}"
cd /opt/novnc
./utils/websockify/run --web /opt/novnc localhost:6080 localhost:${VNC_PORT} > /dev/null 2>&1 &

if [ "$USE_CLOUDFLARE" = "true" ]; then
    echo -e "${CYAN}[+] Starting Cloudflare Tunnel...${NC}"
    cloudflared tunnel --url http://localhost:6080 --no-autoupdate > /home/container/cloudflare.log 2>&1 &
    sleep 5
    CF_URL=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' /home/container/cloudflare.log)
    echo -e "${CYAN}URL: ${CF_URL}${NC}"
fi

sleep 2
cd /home/container

export FORWARD_PORTS="${FORWARD_PORTS//\$\{SERVER_PORT\}/$SERVER_PORT}"
export FORWARD_PORTS="${FORWARD_PORTS//\$SERVER_PORT/$SERVER_PORT}"
MODIFIED_STARTUP="${STARTUP//\{\{SERVER_PORT\}\}/$SERVER_PORT}"
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

MONITOR_PORT=45454
MODIFIED_STARTUP="${MODIFIED_STARTUP//-monitor unix:qemu-monitor.sock,server,nowait/-monitor tcp:127.0.0.1:${MONITOR_PORT},server,nowait}"
[[ ! "$MODIFIED_STARTUP" =~ "-monitor" ]] && MODIFIED_STARTUP="${MODIFIED_STARTUP} -monitor tcp:127.0.0.1:${MONITOR_PORT},server,nowait"

echo -e "${GREEN}[+] Starting QEMU...${NC}"
eval ${MODIFIED_STARTUP} &
QEMU_PID=$!

shutdown_vm() {
    echo -e "\n${YELLOW}[!] Sending ACPI system_powerdown to QEMU Monitor...${NC}"
    echo "system_powerdown" | nc 127.0.0.1 ${MONITOR_PORT} 2>/dev/null
    
    # Chờ VM tắt mềm tối đa 30 giây
    local count=0
    while kill -0 $QEMU_PID 2>/dev/null; do
        sleep 2
        count=$((count + 2))
        [ $count -ge 30 ] && { kill -KILL $QEMU_PID 2>/dev/null; break; }
    done
    exit 0
}

trap shutdown_vm SIGTERM SIGINT

sleep 3
echo -e "${GREEN}[+] Connecting to Serial Console...${NC}"

socat - tcp:127.0.0.1:53211 &
SOCAT_PID=$!

wait $QEMU_PID 2>/dev/null
