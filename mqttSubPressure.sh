#!/bin/bash

BROKER="localhost"

USER="zugZug"
PWD="workWork"

TOPIC="$USER/count"

QOS="0"

SCRIPT_TO_RUN="/home/emli/take_photo_external.sh"

mosquitto_sub -h $BROKER -u $USER -P $PWD -t $TOPIC -q $QOS | while read -r message; do
    echo "Received message: $message" >> /home/emli/pics/logs.txt
    bash "$SCRIPT_TO_RUN" 
done 
