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

          # Create the JSON payload
          JSON_PAYLOAD=$(cat <<EOF
          {
            "model": "llava:7b",
            "messages": [
              {
                "role": "user",
                "content": "Can you tell me what the following image depicts in 4 words?",
                "images": ["$BASE64_ENCODED"]
              }
            ],
            "stream": false
          }
EOF
          )

          # Save the JSON payload to a temporary file
          JSON_TEMP_FILE=$(mktemp)
          echo "$JSON_PAYLOAD" > "$JSON_TEMP_FILE"

          # Send the request using curl
          RESPONSE=$(curl --location 'http://localhost:11434/api/chat' \
          --header 'Content-Type: application/json' \
          --data @"$JSON_TEMP_FILE")

          # Clean up the temporary file
          rm "$JSON_TEMP_FILE"

          # Parse the response to extract the model and content
          MODEL=$(echo "$RESPONSE" | jq -r '.model')
          CONTENT=$(echo "$RESPONSE" | jq -r '.message.content')

          # Update the JSON file with the Annotation field
          jq --arg model "$MODEL" --arg content "$CONTENT" '.Annotation = {"Source": $model, "Content": $content}' "$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"

          TARGET_DIR="../annotatedPics/$SUBDIR"

          FINAL_TARGET_DIR="${TARGET_DIR/\.\/pics\//}"

          mkdir -p "$FINAL_TARGET_DIR"

          mv "$JSON_FILE" "$FINAL_TARGET_DIR"

          echo "Annotation updated and moved to $FINAL_TARGET_DIR"

          rm "$JPG_FILE"

        else
          echo "No matching JSON file for: $JPG_FILE"
        fi
      else
        echo "No .jpg files found in $SUBDIR"
      fi
    done
  fi
done


# Add new json files to git
git add ../annotatedPics/

# Commits new annotated pictures
git commit -m "Annotated new pictures"

# Push changes to git
git push