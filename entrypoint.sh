#!/bin/bash
cd /home/container

VNC_PORT=5901

echo "[+] QEMU VNC :1 → 5901"
echo "[+] noVNC Web :$SERVER_PORT"

MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
eval ${MODIFIED_STARTUP} &

sleep 2

cd /opt/novnc

./utils/novnc_proxy \
  --vnc localhost:${VNC_PORT} \
  --listen 0.0.0.0:${SERVER_PORT}
