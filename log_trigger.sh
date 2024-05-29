#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <trigger_message>"
    exit 1
fi

TIME=$(date +"%d/%m/%Y %H:%M:%S")
echo "$TIME $1" >> /home/emli/pics/logs.txt
