#!/bin/bash

# Variables
IMAGE_DIR="/home/emli/pics"
MOTION_CHECK_SCRIPT="/home/emli/motion_detect.py"
DELAY=3   # Delay in seconds
KEEP_IMAGE=false

# Create the image directory if it doesn't exist
sudo -uemli mkdir -p "$IMAGE_DIR"

prev_image=""
current_image=""

while true; do
    # Generate a timestamp-based image filename
    DATE=$(date +"%H%M%S_%3N")
    FILENAME="$DATE.jpg"
    DATE2=$(date +"%Y-%m-%d")
    sudo -uemli mkdir -p "$IMAGE_DIR/$DATE2"
    current_image="$IMAGE_DIR/$DATE2/$FILENAME"

    rpicam-still -t 0.01 -o "$current_image"

    # Check if there is a previous image to compare against
    if [ -n "$prev_image" ]; then
        # Use the motion check script to check for motion
	motion_result=$(python3 "$MOTION_CHECK_SCRIPT" "$prev_image" "$current_image")
        if [ "$motion_result" == "Motion detected"  ]; then
            # If motion is detected, set the flag to keep the last picture
            KEEP_IMAGE=true
	    # Extract metadata using exiftool
	    METADATA=$(exiftool -json "$current_image")
	    JSON_FILENAME="${FILENAME%.*}.json"  # Removing extension .jpg and appending .json
	    # Extract subject distance, exposure time, and ISO from metadata
	    SUBJECT_DISTANCE=$(echo "$METADATA" | jq -r '.[0]."SubjectDistance"')
	    EXPOSURE_TIME=$(echo "$METADATA" | jq -r '.[0]."ExposureTime"')
	    ISO=$(echo "$METADATA" | jq -r '.[0]."ISO"')

	    # Create JSON data
	    JSON_DATA=$(cat <<EOF
	    {
  	      "File Name": "$FILENAME",
  	      "Create Date": "$(date +"%Y-%m-%d %H:%M:%S.%3N%:z")",
  	      "Create Seconds Epoch": $(date +"%s.%3N"),
  	      "Trigger": "Motion",
  	      "Subject Distance": "$SUBJECT_DISTANCE",
  	      "Exposure Time": "$EXPOSURE_TIME",
     	      "ISO": "$ISO"
	    }
EOF
	    )

	    # Write JSON data to file
	    echo "$JSON_DATA" > "$IMAGE_DIR/$DATE2/$JSON_FILENAME"

	    TIME=$(date +"%d/%m/%Y %H:%M:%S")
	    echo "$TIME Took photo with flag: Motion" >> /home/emli/pics/logs.txt


        fi

	# Before removing prev_image, check for a JSON file with the same base name
        JSON_FILE="${prev_image%.*}.json"

        if [ -f "$JSON_FILE" ]; then
            echo "JSON file exists for $prev_image, keeping image file."
        else
            # If no JSON file exists, remove the previous image
            rm "$prev_image"
        fi
    fi
    
    # Update the previous image to the current one
    prev_image="$current_image"
    
    # If motion was detected and we need to keep the last picture
    if $KEEP_IMAGE; then
        echo "Motion detected! Keeping image: $prev_image"
        KEEP_IMAGE=false  # Reset the flag
    fi
    
    # Delay for the specified time interval
    sleep $DELAY
done
