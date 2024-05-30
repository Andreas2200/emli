from flask import Flask, jsonify, json, request
import base64
import os
import hashlib

app = Flask(__name__)

# Directory where the photos are stored
photos_directory = "/home/emli/pics/"

# File to store copied photo names
copied_photos_file = "/home/emli/copied_photos.txt"

copied_photos = set()

def calculate_md5(file_path):
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

# Load copied photo names from file if it exists
def load_copied_photos():
    copied_photos = set()
    if os.path.exists(copied_photos_file):
        with open(copied_photos_file, "r") as f:
            for line in f:
                photo_name = line.strip()  # Remove leading/trailing whitespace and newline characters
                copied_photos.add(photo_name)
    return copied_photos

def get_not_copied_photos():
    copied_photos = load_copied_photos()

    not_copied = []
    for root, dirs, files in os.walk(photos_directory):
        for filename in files:
            if filename.endswith(".json"):
                folder_name = os.path.basename(root)
                photo_path = os.path.join(folder_name, filename)  # Full path of the photo
                photo_path_without_extension = os.path.splitext(photo_path)[0]  # Remove the .json extension
                if photo_path_without_extension not in copied_photos:
                    print(photo_path_without_extension)
                    not_copied.append(photo_path_without_extension)
    return not_copied

# Endpoint for the drone to request photos it hasn't copied
@app.route('/api/not_copied_photos', methods=['GET'])
def not_copied_photos():
    return jsonify(get_not_copied_photos())

# Endpoint for the drone to acknowledge receipt of a photo
@app.route('/api/acknowledge_photo', methods=['POST'])
def acknowledge_photo():
    data = request.json
    photo_name = data.get('photo_name')
    metadata = data.get('metadata')

    # Extract "Seconds Epoch" and "Drone ID" from metadata
    drone_id = metadata.get('Drone ID')
    seconds_epoch = metadata.get('Seconds Epoch')

    # Update metadata file with drone copied JSON
    copied_photos = load_copied_photos()
    copied_photos.add(photo_name)

    # Write copied photo names to file
    with open(copied_photos_file, "a") as f:
        f.write(photo_name + "\n")

    # Update metadata file for the acknowledged photo
    metadata_file = photos_directory + os.path.splitext(photo_name)[0] + ".json"
    drone_copy_info = {
        "Drone Copy": {
            "Drone ID": drone_id,
            "Seconds Epoch": seconds_epoch
        }
    }
    with open(metadata_file, "r+") as f:
        metadata_json = json.load(f)
        metadata_json.update(drone_copy_info)
        f.seek(0)
        json.dump(metadata_json, f, indent=4)

    return jsonify({'message': 'Acknowledged receipt of photo'}), 200


@app.route('/api/set_time', methods=['POST'])
def set_time():
    data = request.json
    if 'time' not in data:
        return jsonify({"error": "time is required"}), 400
    try:
        # Set the system time
        newTime = data.get("time")
        os.system(f'sudo timedatectl set-time {newTime}')
        return jsonify({"message": "Time successfully set"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/get_image/<directory>/<filename>', methods=['GET'])
def get_image_with_metadata(directory, filename):

    full_filename = directory+"/"+filename

    # Create the full paths to the image file and metadata file
    image_path = os.path.join(photos_directory, full_filename + ".jpg")
    metadata_path = os.path.join(photos_directory, full_filename + ".json")
    print(image_path)
    print(metadata_path)

    if not os.path.exists(image_path) or not os.path.exists(metadata_path):
        return jsonify({"description":"Image or metadata not found"}), 404

    # Read metadata from the JSON file
    with open(metadata_path, 'r') as meta_file:
        metadata = json.load(meta_file)

    # Encode the image to base64
    with open(image_path, 'rb') as img_file:
        encoded_image = base64.b64encode(img_file.read()).decode('utf-8')

    md5_hash = calculate_md5(image_path)

    # Prepare the response data
    response_data = {
        'metadata': metadata,
        'image': encoded_image,
        'md5': md5_hash
    }

    return jsonify(response_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
