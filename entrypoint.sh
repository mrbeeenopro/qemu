#!/bin/bash
cd /home/container

VNC_PORT=5901

echo "[+] QEMU VNC :1 → 5901"
echo "[+] noVNC Web :$SERVER_PORT"

MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
eval ${MODIFIED_STARTUP} &

sleep 2

cd /opt/novnc

./utils/websockify/run \
  --web /opt/novnc \
  0.0.0.0:${SERVER_PORT} \
  localhost:${VNC_PORT}
