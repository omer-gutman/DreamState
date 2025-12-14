from flask import Flask, request, jsonify
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import threading
import requests
import time
import os

app = Flask(__name__)

# --- CONFIGURATION (FILL THESE IN) ---
EMAIL_ADDRESS = ""
EMAIL_PASSWORD = "" 
SEND_TO = ""

# GET KEY FROM: https://lumalabs.ai/ (Dream Machine API)
LUMA_API_KEY = ""

def generate_dream_recorder_video(dream_text, sleep_score):
    print(f"🎬 Activting Dream Recorder for: {dream_text}")
    
    # --- THE DREAM RECORDER AESTHETIC LOGIC ---
    # We use specific camera prompts to mimic the "Dream Recorder" style
    # (Low definition, 35mm film, hazy, nostalgic, surreal)
    
    base_style = "shot on 35mm film, grainy, hazy, nostalgic, low definition, dreamcore aesthetic"
    
    if sleep_score < 50:
        mood = "dark, foggy, nightmarish, surreal, shadowy figures"
    else:
        mood = "ethereal, bright, soft lighting, bloom effect, peaceful"
        
    full_prompt = f"A first-person point of view shot of {dream_text}. {base_style}, {mood}"

    # 1. Send Request to Luma Labs
    url = "https://api.lumalabs.ai/dream-machine/v1/generations"
    headers = {
        "Authorization": f"Bearer {LUMA_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "prompt": full_prompt,
        "model": "ray-flash-2",
        "aspect_ratio": "16:9",
        "resolution": "540p",
        "loop": True # Dream Recorder videos often loop
    }

    try:
        # Start Generation
        response = requests.post(url, json=payload, headers=headers)
        data = response.json()
        
        if 'id' not in data:
            print(f"❌ Luma Error: {data}")
            return

        generation_id = data['id']
        print(f"⏳ Generation {generation_id} started... (takes ~2 mins)")

        # 2. Wait loop
        video_url = None
        for _ in range(60): # Wait up to 5 minutes
            time.sleep(5)
            check_url = f"{url}/{generation_id}"
            status_resp = requests.get(check_url, headers=headers).json()
            
            state = status_resp.get("state")
            if state == "completed":
                video_url = status_resp['assets']['video']
                print(f"✅ Video Finished! URL: {video_url}")
                break
            elif state == "failed":
                print("❌ Generation Failed.")
                return

        if video_url:
            download_and_email(dream_text, video_url)

    except Exception as e:
        print(f"❌ Error: {e}")

def download_and_email(dream_text, video_url):
    # Download the MP4 first
    print("⬇️ Downloading video...")
    r = requests.get(video_url)
    filename = "dream_recorder_output.mp4"
    with open(filename, 'wb') as f:
        f.write(r.content)
        
    # Create Email
    msg = MIMEMultipart()
    msg['From'] = EMAIL_ADDRESS
    msg['To'] = SEND_TO
    msg['Subject'] = f"Dream Recorder: {dream_text}"
    body = f"Your subconscious has been visualized.\n\nDream: '{dream_text}'\nLogic: Luma Dream Machine"
    msg.attach(MIMEText(body, 'plain'))

    # Attach Video
    with open(filename, "rb") as attachment:
        part = MIMEBase("application", "octet-stream")
        part.set_payload(attachment.read())
    
    encoders.encode_base64(part)
    part.add_header('Content-Disposition', f"attachment; filename={filename}")
    msg.attach(part)

    # Send
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        server.send_message(msg)
        server.quit()
        print("🚀 Video Sent to Inbox!")
    except Exception as e:
        print(f"❌ Email Failed: {e}")

@app.route('/generate', methods=['POST'])
def handle_request():
    data = request.json
    dream_text = data.get('dream_text', 'Flying')
    sleep_score = data.get('sleep_score', 50)
    
    print(f"🌟 Input Received: {dream_text}")

    # Run in background
    thread = threading.Thread(target=generate_dream_recorder_video, args=(dream_text, sleep_score))
    thread.start()

    return jsonify({"status": "success", "message": "Dream Recorder Activated"})

if __name__ == '__main__':
    app.run(debug=True, port=5000)