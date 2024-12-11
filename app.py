from flask import Flask, request, jsonify
from keras.models import load_model
from PIL import Image, ImageOps
import numpy as np
import os

app = Flask(__name__)

# Load the model and labels (ensure paths are correct)
model = load_model("keras_model.h5", compile=False)
class_names = open("labels.txt", "r").readlines()

# Function to process the image and return the prediction
def process_image(image):
    # Resize and normalize the image
    size = (224, 224)
    image = ImageOps.fit(image, size, Image.Resampling.LANCZOS)
    image_array = np.asarray(image)
    normalized_image_array = (image_array.astype(np.float32) / 127.5) - 1

    # Prepare the data for prediction
    data = np.ndarray(shape=(1, 224, 224, 3), dtype=np.float32)
    data[0] = normalized_image_array

    # Perform prediction
    prediction = model.predict(data)
    index = np.argmax(prediction)
    class_name = class_names[index]
    confidence_score = prediction[0][index]

    return class_name[2:], confidence_score

# Route to handle image prediction requests
@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    # Load the image from the request
    image = request.files["image"]
    img = Image.open(image.stream).convert("RGB")

    # Get the class name and confidence score
    class_name, confidence = process_image(img) 

    # Return the result as a JSON response
    return jsonify({"class_name": class_name, "confidence_score": float(confidence)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)