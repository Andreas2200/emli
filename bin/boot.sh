#!/bin/bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
/home/emli/mqttSubPressure.sh > /dev/null 2>&1 &
/home/emli/start_local_webserver.sh > /dev/null 2>&1 &
/home/emli/picEverySec.sh > /dev/null 2>&1 &
sudo -uemli python3 /home/emli/flaskserver.py > /dev/null 2>&1 &
/home/emli/serialListen.sh > /dev/null 2>&1 &
/home/emli/mqttSubRainDetect.sh > /dev/null 2>&1 &
/home/emli/mqttSubRainWipeSerialWrite.sh > /dev/null 2>&1 &
