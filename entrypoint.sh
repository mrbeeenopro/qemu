#!/bin/bash
cd /home/container

# Fix QEMU temp write
export TMPDIR=/home/container/tmp
mkdir -p $TMPDIR

VNC_PORT=5901

cd /opt/novnc

./utils/websockify/run \
  --web /opt/novnc \
  0.0.0.0:${SERVER_PORT} \
  localhost:${VNC_PORT}
echo "[+] QEMU VNC :1 → 5901"
echo "[+] noVNC Web :$SERVER_PORT"

sleep 2

cd /home/container

MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')

eval exec ${MODIFIED_STARTUP}

