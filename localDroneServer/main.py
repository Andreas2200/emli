import requests
import base64
import hashlib
import time

wildlife_camera_ip = "http://10.0.0.10:5000"


def test_connection():
    try:
        req = requests.get(wildlife_camera_ip + "/api/not_copied_photos")
        print("Connection established")
        if(req.text):
            return req.json()
    except Exception as e:
        print("No connection to wildlife camera")
        time.sleep(5)
        return test_connection()

def get_pictures(picture_path):
    print(f'Getting picture {picture_path}')
    res = requests.get(wildlife_camera_ip + "/api/get_image/" + picture_path)
    data = res.json()
    metadata = data.get('metadata')
    encoded_image = data.get('image')
    md5 = data.get('md5')
    print(metadata)
    print(md5)

images = test_connection()
print(images)
get_pictures(images[0])
