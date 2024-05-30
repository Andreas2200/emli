import requests
import base64
import hashlib
import time
import os
import json

wildlife_camera_ip = "http://192.168.10.1:5000"
drone_id = "WILDDRONE-001"
photos = "./pics/"

def calculate_md5(file_path):
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def list_images():
    req = requests.get(wildlife_camera_ip + "/api/not_copied_photos")
    return req.json()

def test_connection(tries = 0, max_tries = 5):
    if(tries >= max_tries):
        return False
    try:
        req = requests.get(wildlife_camera_ip + "/api/heartbeat")
        if req.status_code == 200:
            print("Connection good")
            return True
        else:
            print("No connection to wildlife camera")
            time.sleep(1) 
            return test_connection(tries+1, max_tries)
    except Exception as e:
        print("No connection to wildlife camera")
        time.sleep(1)
        return test_connection(tries+1, max_tries)

def get_picture(picture_path):
    print(f'Getting picture {picture_path}')
    
    picture_directory, _ = picture_path.split("/")
    os.makedirs(photos + picture_directory, exist_ok=True)
    
    res = requests.get(wildlife_camera_ip + "/api/get_image/" + picture_path)
    data = res.json()
    
    metadata = data.get('metadata')
    encoded_image = data.get('image')
    md5 = data.get('md5')
    
    image_data = base64.b64decode(encoded_image)
    with open(photos+picture_path+".jpg", 'wb') as file:
        file.write(image_data)
    
    md5_hash = calculate_md5(photos+picture_path+".jpg")
    if md5_hash != md5:
        print("Hash isn't correct")
        return get_picture(picture_path)

    with open(photos+picture_path+".json", 'w') as file:
        json.dump(metadata, file, indent=4)

    json_data = {
        "photo_name": picture_path,
        "metadata": {
            "Drone ID": drone_id,
            "Seconds Epoch": time.time()
        }
    }

    requests.post(wildlife_camera_ip + "/api/acknowledge_photo", json=json_data)


def offload_picture_from_camera():
    if test_connection() == False:
        print("No connection to wildlife camera, shutting down")
        exit()
    images = list_images()
    if len(images) < 1:
        print("No images to download")
        exit()
    time_start = int(time.time())
    for image in images:
        get_picture(image)
        if test_connection(max_tries=2) == False:
            print("No connection to wildlife camera, shutting down")
            exit()
    print("All images downloaded")
    print(f'It took {int(time.time())-time_start} ms to get {len(images)} images')



if __name__ == '__main__':
    offload_picture_from_camera()