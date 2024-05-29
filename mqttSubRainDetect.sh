#!/bin/bash

BROKER="localhost"

USER="zugZug"
PWD="workWork"

TOPIC="$USER/rain"
TOPICPUB="$USER/wiper"

QOS="0"

mosquitto_sub -h $BROKER -u $USER -P $PWD -t $TOPIC -q $QOS | while read -r message; do
    echo "Received message: $message"
    mosquitto_pub -h $BROKER -u $USER -P $PWD -t $TOPICPUB -m '{"wiper_angle": 0}'
    mosquitto_pub -h $BROKER -u $USER -P $PWD -t $TOPICPUB -m '{"wiper_angle": 180}'
    mosquitto_pub -h $BROKER -u $USER -P $PWD -t $TOPICPUB -m '{"wiper_angle": 0}'
done
