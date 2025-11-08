🍽️ BiteCheck — Your Smart AI Nutrition Companion

BiteCheck is an AI-powered mobile application built using Flutter and FastAPI that helps users make smarter food choices by instantly analyzing meals through image recognition.
It predicts nutritional information, tracks calories and macros, and gives daily insights tailored to your health goals.

🚀 Features
🔍 AI-Powered Food Recognition

Instantly identify food items using your camera.

Works for complex Indian and global dishes.

Integrated with Food101 dataset (TFLite model).

🍎 Nutrition Insights

Calculates calories, protein, carbs, and fats per meal.

Integrates with Edamam/Nutritionix APIs for accurate nutritional data.

Personalized daily goals based on user’s profile (age, weight, height, gender, goal).

📊 Smart Dashboard

Interactive charts for daily Calorie, Protein, Carb, and Fat intake.

Visual progress tracking with motivational insights.

Real-time updates after each scan.

🧠 Personalized Health Profile

Collects basic info: Name, Age, Height, Weight, Gender, Goal (Gain/Lose/Maintain).

Automatically calculates daily calorie targets using BMR formula.

🔔 Notifications

Smart reminders to log meals and water intake.

“You’re 200 kcal away from your goal!” type pop-ups.

🌗 Dark Mode Support (coming soon)

Sleek green-and-black interface for better visual comfort.

🧩 Tech Stack
Layer	Technologies Used
Frontend	Flutter, Dart, Riverpod, FL Chart
Backend	FastAPI (Python), TensorFlow Lite (TFLite), Edamam API
Model	Custom-trained Food Classification (Food101 dataset)
Database (future)	Firebase / PostgreSQL
Hosting	Render / Hugging Face Spaces / Google Cloud (optional)
📱 App Flow
Splash Screen → Login → Profile Setup → Dashboard → Food Scan → Nutrition Insights


Screens included:

SplashScreen (Animated logo)

LoginScreen (Basic auth)

ProfileSetupScreen (User data input)

NutritionDashboardScreen (Charts + Notifications)

NotificationWidget (daily reminders UI)

🧠 How It Works

User opens app → Enters personal details.

Camera scan or search → Food item identified using TFLite model.

Backend (FastAPI) → Returns nutrition details via Edamam API.

Frontend Dashboard → Displays calories, macros, and visual graphs.

Notification system → Sends reminders for meal tracking.

⚙️ Installation & Setup
🧭 Prerequisites

Flutter SDK 3.0+

Python 3.10+

Node.js (optional)

Git

🧱 Clone the Project
git clone https://github.com/<your-username>/BiteCheck.git
cd BiteCheck

🧩 Backend Setup

Navigate to backend folder:

cd backend


Install dependencies:

pip install -r requirements.txt


Run the FastAPI server:

uvicorn main:app --reload


Backend will run on → http://127.0.0.1:8000/docs

📲 Frontend (Flutter) Setup

Navigate to Flutter folder:

cd flutter_application_1


Get dependencies:

flutter pub get


Run the app:

flutter run

🤖 AI Model

Dataset: Food-101

Framework: TensorFlow

Exported as: food_model_v3.tflite

Integration: FastAPI backend

Trained with MobileNet architecture for efficient edge prediction.

🧠 Future Improvements

 Add Firebase Auth & Cloud Sync

 Include Water Intake Tracking

 AI Chatbot for Meal Suggestions

 Dark Mode Support

 Multilingual Support (Hindi, English, etc.)




 still work in progress
