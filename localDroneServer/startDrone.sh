#!/bin/bash

# Define the SSID of the wildlife camera's access point
WILDLIFE_CAMERA_SSID="EMLI-TEAM-21"
WILDLIFE_CAMERA_IP="192.168.10.1"

# Function to check if we are connected to the raspberry pi
is_connected_to_ssid() {
    current_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d':' -f2)
    if [ "$current_ssid" == "$WILDLIFE_CAMERA_SSID" ]; then
        return 0
    else
        return 1
    fi
}

# Main loop to check for the SSID and sync time
while true; do
    if is_connected_to_ssid; then
        echo "Wildlife camera SSID detected. Starting other drone services"
        python3 main.py &
        ./sync_time.sh &
        ./measure_wifi.sh &
        # Exit the loop after successful sync
        break
    else
        echo "Wildlife camera SSID not detected. Retrying in 5 seconds..."
        sleep 5
    fi
done
