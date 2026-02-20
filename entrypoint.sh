#!/bin/bash
cd /home/container

VNC_PORT=5901

echo "[+] QEMU start display on :1 -> port 5901"
echo "[+] noVNC web :$SERVER_PORT"

MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Run VM
eval ${MODIFIED_STARTUP} &

sleep 2

cd /opt/novnc

# Serve web
python3 -m http.server ${SERVER_PORT} &

sleep 1

# Bridge VNC
./utils/novnc_proxy --vnc localhost:${VNC_PORT} --listen ${SERVER_PORT}
