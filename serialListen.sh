#!/bin/bash

DEVICE="/dev/ttyACM0"

BAUD_RATE="115200"

if [ ! -c "$DEVICE" ]; then
    echo "Error: Device $DEVICE not found."
    exit 1;
fi

stty -F "$DEVICE" "$BAUD_RATE" raw -echo

echo "Reading from $DEVICE at $BAUD_RATE baud rate..."

BROKER="localhost"
USER="zugZug"
PWD="workWork"
QOS="0"
TOPIC="$USER/rain"

cat "$DEVICE" | while IFS= read -r message; do
    if [[ "$message" == *'"rain_detect": 1'* ]]; then
        echo "Received message with rain_detect=1: $message" >> /home/emli/pics/logs.txt
	mosquitto_pub -h $BROKER -u $USER -P $PWD -t $TOPIC -m "$message"
    fi
done
