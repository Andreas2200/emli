#!/bin/bash

# Define the SSID of the wildlife camera's access point
WILDLIFE_CAMERA_SSID="EMLI-TEAM-21"
WILDLIFE_CAMERA_IP="10.0.0.10"
SYNC_PORT=22  # Default SSH port

# Function to check if we are connected to the raspberry pi
is_connected_to_ssid() {
    current_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d':' -f2)
    if [ "$current_ssid" == "$WILDLIFE_CAMERA_SSID" ]; then
        return 0
    else
        return 1
    fi
}

# Function to sync time with the wildlife camera
sync_time() {
    echo "Synchronizing time with wildlife camera: ${current_time}"
    
    # Use SSH to set the time on the wildlife camera
    curl -X POST $WILDLIFE_CAMERA_IP:5000/api/set_time -H "Content-Type: application/json" -d "{\"time\": \"$(date +%H:%M:%S)\"}"
    
    if [ $? -eq 0 ]; then
        echo "Time synchronized successfully."
    else
        echo "Failed to synchronize time."
    fi
}

# Main loop to check for the SSID and sync time
while true; do
    if is_connected_to_ssid; then
        echo "Wildlife camera SSID detected."
        sync_time
        # Exit the loop after successful sync
        break
    else
        echo "Wildlife camera SSID not detected. Retrying in 5 seconds..."
        sleep 5
    fi
done
