import requests
from flask import Flask, request
from flask_cors import CORS
import base64
from PIL import Image
from io import BytesIO

api_url = "https://hf.space/embed/Salesforce/BLIP/+/api/predict/"

app = Flask(__name__)
CORS(app)


@app.route('/caption', methods=['POST'])
def get_caption():
    file = request.files.get("image")
    image = base64.b64encode(file.read())
    image = "data:image/jpeg;base64,"+str(image)[1:-1]
    mode = "Image Captioning"
    question = "None"
    radio = "Beam Search"
    data = requests.post(url=api_url, json={"data": [image,mode,question,radio]})
    data = data.json();
    result = data["data"][0]
    result = result.split(":")[1]
    return {"caption": result}, 200




@app.route('/vqa', methods=['POST'])
def get_answer():
    file = request.files.get("image")
    image = base64.b64encode(file.read())
    image = "data:image/jpeg;base64,"+str(image)[1:-1]
    # print(image)
    mode = "Visual Question Answering"
    question = request.form.get("question")
    radio = "Beam Search"

    data = requests.post(url=api_url, json={"data": [image,mode,question,radio]})
    data = data.json();
    print(data)
    result = data["data"][0]
    result = result.split(":")[1]
    return {"caption": result}, 200


if __name__ == '__main__':
    app.run(debug = False)