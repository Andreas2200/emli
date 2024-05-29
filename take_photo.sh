#!/bin/bash

while getopts t: flag
do
   case "${flag}" in
       t) trigger=${OPTARG};;
   esac
done


DATE=$(date +"%H%M%S_%3N")
DATE2=$(date +"%Y-%m-%d")

FILENAME="$DATE.jpg"
JSON_FILENAME="${FILENAME%.*}.json"  # Removing extension .jpg and appending .json

if ! test -d ~/pics/$DATE2; then
  mkdir ~/pics/$DATE2
fi

# Capture image
rpicam-still -t 0.01 -o ~/pics/$DATE2/$FILENAME

# Extract metadata using exiftool
METADATA=$(exiftool -json ~/pics/$DATE2/$FILENAME)

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
  "Trigger": "$trigger",
  "Subject Distance": "$SUBJECT_DISTANCE",
  "Exposure Time": "$EXPOSURE_TIME",
  "ISO": "$ISO"
}
EOF
)

# Write JSON data to file
echo "$JSON_DATA" > ~/pics/$DATE2/$JSON_FILENAME
/home/emli/log_trigger.sh "Took photo with flag: $trigger"
