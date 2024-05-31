#!/bin/bash

#Star by moving pictures into own folder
#cp ../localDroneServer/pics ./pics


TEST=$(base64 -w 0 ./pics/2024-05-30/210515_111.jpg)




BASE_DIR="./pics"

# Iterate over each subdirectory in the base directory
for SUBDIR in "$BASE_DIR"/*; do
  if [ -d "$SUBDIR" ]; then
    echo "Processing directory: $SUBDIR"
    
    # Iterate over each .jpg file in the current subdirectory
    for JPG_FILE in "$SUBDIR"/*.jpg; do
      if [ -f "$JPG_FILE" ]; then
        BASE_NAME=$(basename "$JPG_FILE" .jpg)

        JSON_FILE="$SUBDIR/$BASE_NAME.json"
        if [ -f "$JSON_FILE" ]; then
          echo "Processing file: $JPG_FILE"
        
          # Base64 encode the .jpg file
          BASE64_ENCODED=$(base64 -w 0 "$JPG_FILE")
        
          curl --location 'http://localhost:11434/api/chat' \
          --header 'Content-Type: application/json' \
          --data "{
          \"model\": \"llava:7b\",
          \"messages\": [
            {
              \"role\": \"user\",
              \"content\": \"Can you tell me what the following image depicts in 4 words?\",
              \"images\": [\"$BASE64_ENCODED\"]
            }
          ],
          \"stream\": false
          }"
        else
          echo "No matching JSON file for: $JPG_FILE"
        fi
      else
        echo "No .jpg files found in $SUBDIR"
      fi
    done
  fi
done