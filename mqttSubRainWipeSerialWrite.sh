#!/bin/bash

BROKER="localhost"

USER="zugZug"
PWD="workWork"

TOPIC="$USER/wiper"
QOS="0"

DEVICE="/dev/ttyACM0"

mosquitto_sub -h $BROKER -u $USER -P $PWD -t $TOPIC -q $QOS | while read -r message; do
    echo "$message" > $DEVICE
done

