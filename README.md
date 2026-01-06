DreamState (DreamCatcher)
DreamState is a unique "Dream Recorder" system that bridges the gap between your subconscious and reality. It consists of a Garmin Watch App (DreamCatcher) that allows users to log their dreams immediately upon waking, and a Python Backend that visualizes those dreams into AI-generated videos using Luma Labs, emailing the result directly to the user.

🌟 Overview
The system works in a simple loop:

Capture: The user wakes up and opens the DreamCatcher app on their Garmin watch.

Input: They select a common dream theme (e.g., "Flying", "Falling") or type a custom description using the watch keyboard.

Context: The app retrieves the user's "Body Battery" (Sleep Score) to determine the emotional tone of the dream (e.g., low battery = "nightmarish/foggy", high battery = "ethereal/bright").

Generation: The data is sent to a Python backend, which uses the Luma Dream Machine API to generate a nostalgic, 35mm-style visualization of the dream.

Delivery: The generated video is emailed to the user as a "Dream Record."

📂 Repository Structure
DreamCatcher/: Source code for the Garmin Connect IQ watch application.

source/: Monkey C logic for views, menus, and HTTP requests.

resources/: Layouts, strings, and drawables (monkey icons, menus).

manifest.xml: App permissions and configuration.

backend/: Python Flask server handling API requests and AI generation.

app.py: Main server script handling HTTP POST requests, Luma API integration, and email dispatch.

🚀 Features
Garmin Integration: Built with Monkey C for Garmin devices.

Biometric Context: Uses Toybox.SensorHistory to read Body Battery data, influencing the AI generation style.

Custom Input: Supports both predefined menu keywords and a native text picker for custom dream logging.

AI Video Generation: Integrates with Luma Labs (Ray-Flash-2 model) to create 16:9, 35mm film-style videos.

Automated Delivery: Automatically downloads the generated video and emails it via SMTP.

🛠️ Prerequisites
Hardware
A Garmin Device (Connect IQ 5.0.0+ compatible).

Software & Accounts
Garmin Connect IQ SDK (for building the watch app).

Python 3.x (for the backend).

Luma Labs API Key (for video generation).

Gmail Account (with App Password) for sending emails.

Ngrok (or similar tool to tunnel your localhost to the internet).

⚙️ Setup Instructions
1. Backend Setup (Python)
Navigate to the backend/ directory.

Install required dependencies (you may need a virtual environment):

Bash

pip install flask requests
Open backend/app.py and configure the following variables:

Python

EMAIL_ADDRESS = "your_email@gmail.com"
EMAIL_PASSWORD = "your_app_password"
SEND_TO = "recipient_email@gmail.com"
LUMA_API_KEY = "your_luma_api_key"
Run the server:

Bash

python app.py
Expose your server to the internet (e.g., using Ngrok):

Bash

ngrok http 5000
Copy the HTTPS URL provided by Ngrok (e.g., https://your-id.ngrok-free.dev).

2. Frontend Setup (Garmin)
Open the DreamCatcher project in VS Code with the Monkey C extension.

Open source/DreamMenuDelegate.mc.

Find the DreamSender class and update the URL variable with your Ngrok URL:

Code snippet

var URL = "https://your-id.ngrok-free.dev/generate";
Build and run the project in the Garmin Simulator or sideload it to your device.

📱 Usage
Open the App: Launch "DreamCatcher" on your watch.

Start: Press the Select/Enter button (or tap the screen) to open the menu.

Log a Dream:

Select a keyword (Flying, Falling, Chasing, Water, Family).

OR Select "Write Own..." to type a custom description.

Wait: The watch will show "Generating..." followed by "Check Email!" upon success.

View: Check your email inbox for the "Dream Recorder" video attachment.

🧩 Permissions
The Garmin app requires the following permissions (defined in manifest.xml):

Communications: To send the dream data to the backend.

SensorHistory: To access Body Battery/Sleep scores.

⚠️ Notes
Ngrok URL: The Ngrok URL changes every time you restart Ngrok (unless you have a paid plan). You must update the URL in DreamMenuDelegate.mc and rebuild the app if the URL changes.

Luma API: Video generation typically takes ~2-5 minutes. The Python script handles the waiting logic automatically.
