from flask import Flask, request, jsonify
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.image import MIMEImage
import threading
import requests # You might need to install this: pip install requests
import time

app = Flask(__name__)

# --- CONFIGURATION ---
EMAIL_ADDRESS = "to slow.com"  
EMAIL_PASSWORD = "nope" 
SEND_TO = "yeah still no.com"      

def generate_and_email(dream_text, sleep_score):
    print(f"🎨 Generating Image for: {dream_text}")
    
    # 1. Create Prompt
    style = "dark, gloomy, blurry, abstract art" if sleep_score < 50 else "vibrant, ethereal, cinematic, 4k"
    final_prompt = f"{dream_text}, {style}"
    
    # 2. Get Image from Pollinations (Free, No Key needed)
    image_url = f"https://image.pollinations.ai/prompt/{final_prompt}"
    
    try:
        # Download the image to send it
        response = requests.get(image_url)
        if response.status_code == 200:
            image_data = response.content
            print("✅ Image Downloaded. Sending Email...")
            send_email(dream_text, image_data)
        else:
            print("❌ Failed to download image from AI.")
            
    except Exception as e:
        print(f"❌ Error: {e}")

def send_email(dream_text, image_data):
    msg = MIMEMultipart()
    msg['From'] = EMAIL_ADDRESS
    msg['To'] = SEND_TO
    msg['Subject'] = f"Dream Visual: {dream_text}"

    body = f"Here is the AI visualization of your dream: '{dream_text}'."
    msg.attach(MIMEText(body, 'plain'))

    # Attach the Image
    image = MIMEImage(image_data, name="dream.jpg")
    msg.attach(image)

    # Login and Send
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        server.send_message(msg)
        server.quit()
        print("🚀 Email Sent Successfully!")
    except Exception as e:
        print(f"❌ Email Failed: {e}")

@app.route('/generate', methods=['POST'])
def handle_request():
    data = request.json
    dream_text = data.get('dream_text', 'Flying')
    sleep_score = data.get('sleep_score', 50)
    
    print(f"🌟 Request Received: {dream_text}")

    # Run in background so watch doesn't freeze
    thread = threading.Thread(target=generate_and_email, args=(dream_text, sleep_score))
    thread.start()

    return jsonify({"status": "success", "message": "Generating Image..."})

if __name__ == '__main__':
    app.run(debug=True, port=5000)