#!/bin/bash

# Define the SSID of the wildlife camera's access point
WILDLIFE_CAMERA_SSID="EMLI-TEAM-21"
DB_USER="root"
DB_NAME="wifi_status"
DB_TABLE="status"
DB_HOST="127.0.0.1"

# Function to check if we are connected to the raspberry pi
is_connected_to_ssid() {
    current_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d':' -f2)
    if [ "$current_ssid" == "$WILDLIFE_CAMERA_SSID" ]; then
        return 0
    else
        return 1
    fi
}


wifi_info=$(awk 'NR==3 {print $3, $4}' /proc/net/wireless)

signal_level=$(echo $wifi_info | awk '{print int($1)}')
link_quality=$(echo $wifi_info | awk '{print int($2)}')

seconds_epoch=$(date +%s)

# Main loop to check for the SSID and sync time
mysql -u root -h $DB_HOST < wifi_status.sql

while true; do
    if is_connected_to_ssid; then
        echo "Er på nettet"
        
        mysql -u $DB_USER -h $DB_HOST $DB_NAME <<EOF
        INSERT INTO $DB_TABLE (signal_level, link_quality, seconds_epoch)
        VALUES ($signal_level, $link_quality, $seconds_epoch);
EOF
        sleep 5
    else
        echo "Er ikke længere på nettet"
        sleep 5
    fi
done