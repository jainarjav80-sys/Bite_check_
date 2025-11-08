import os
import numpy as np
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import tensorflow as tf
import io
import requests

app = FastAPI(title="🍽️ BiteCheck Food Recognition API", version="3.1")

# -----------------------------------
# ✅ Enable CORS for Flutter frontend
# -----------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------------
# ✅ Load TFLite model
# -----------------------------------
MODEL_PATH = "food_model_v3.tflite"

if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"❌ Model not found at {MODEL_PATH}. Please place it in the backend folder.")

interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# ✅ Food-101 class labels (shortened list for now)
# You can later import the full list (101 classes)
# -----------------------------------
# ✅ Load class labels dynamically (Food-101)
# -----------------------------------
LABELS_PATH = "labels_food101.txt"

if not os.path.exists(LABELS_PATH):
    raise FileNotFoundError("⚠️ labels_food101.txt not found. Please place it in backend folder.")

with open(LABELS_PATH, "r") as f:
    CLASS_NAMES = [line.strip() for line in f.readlines()]


# -----------------------------------
# ✅ Edamam Nutrition Lookup
# -----------------------------------
def lookup_nutrition_edamam(food_name: str):
    EDAMAM_APP_ID = os.environ.get("EDAMAM_APP_ID")
    EDAMAM_APP_KEY = os.environ.get("EDAMAM_APP_KEY")

    if not EDAMAM_APP_ID or not EDAMAM_APP_KEY:
        print("⚠️ Missing Edamam credentials.")
        return {"error": "API keys missing"}

    url = "https://api.edamam.com/api/nutrition-data"
    params = {
        "app_id": EDAMAM_APP_ID,
        "app_key": EDAMAM_APP_KEY,
        "ingr": food_name
    }

    try:
        r = requests.get(url, params=params)
        data = r.json()
        return {
            "calories": data.get("calories", 0),
            "protein": data.get("totalNutrients", {}).get("PROCNT", {}).get("quantity", 0),
            "fat": data.get("totalNutrients", {}).get("FAT", {}).get("quantity", 0),
            "carbs": data.get("totalNutrients", {}).get("CHOCDF", {}).get("quantity", 0),
        }
    except Exception as e:
        print("Error fetching nutrition:", e)
        return {"error": "Failed to fetch nutrition"}

# -----------------------------------
# ✅ Root route
# -----------------------------------
@app.get("/")
def root():
    return {"message": "🚀 BiteCheck backend running successfully!"}

# -----------------------------------
# ✅ Prediction endpoint
# -----------------------------------
@app.post("/predict")
async def predict_food(file: UploadFile = File(...)):
    try:
        # Read image
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image = image.resize((224, 224))

        # Preprocess for model
        image_array = np.array(image, dtype=np.float32) / 255.0
        image_array = np.expand_dims(image_array, axis=0)

        # Run inference
        interpreter.set_tensor(input_details[0]["index"], image_array)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details[0]["index"])

        prediction_idx = np.argmax(output_data)
        confidence = float(np.max(output_data))

        # Fix "Unknown" issue
        predicted_food = (
            CLASS_NAMES[prediction_idx]
            if prediction_idx < len(CLASS_NAMES)
            else "Unknown"
        )

        # Lookup nutrition
        nutrition = lookup_nutrition_edamam(predicted_food)

        return {
            "predicted_food": predicted_food,
            "confidence": round(confidence * 100, 2),
            "nutrition": nutrition,
        }

    except Exception as e:
        print("❌ Error during prediction:", e)
        return {"error": str(e)}

# -----------------------------------
# ✅ Run with:
# uvicorn main:app --reload
# -----------------------------------

