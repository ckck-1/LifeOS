from flask import Flask, request, jsonify
import os, requests, logging
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
app = Flask(__name__)

# --- Configure Logging ---
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[logging.StreamHandler()]
)

# 2026 Standard: OpenAI-compatible v1 router
HF_API_URL = "https://router.huggingface.co/v1/chat/completions"
HF_TOKEN = os.getenv("HF_API_TOKEN")
HF_MODEL = "Qwen/Qwen2.5-7B-Instruct"

SYSTEM_PROMPT = """
You are LifeOS AI, a high-performance AI life operating system and strategic coach.
Created by: CK — full-stack dev, AI creator, productivity strategist, and community impact enthusiast.

Rules:
  - Respond ONLY in clear, concise, and natural plain text.
  - NEVER use labels or section headers (e.g., do NOT write "**Greeting**:", "**Daily Focus**:", or "Section 1").
  - Start your response directly with your message to the user.
  - NEVER return JSON, code blocks, or raw data structures.
  - Use bullet points for lists, but do not label the list.
  - No extra explanations about being an AI or fluff.

Tone: Direct, high-efficiency, motivational.
"""

# -------------------- /generate Endpoint --------------------
@app.route("/generate", methods=["POST"])
def generate():
    logging.info("Received request to /generate endpoint")
    data = request.json
    user_prompt = str(data.get("prompt", ""))

    payload = {
        "model": HF_MODEL,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt}
        ],
        "max_tokens": 500,
        "temperature": 0.7
    }

    headers = {
        "Authorization": f"Bearer {HF_TOKEN}",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(HF_API_URL, headers=headers, json=payload, timeout=60)
        if response.status_code != 200:
            logging.error(f"Router Error {response.status_code}: {response.text}")
            return jsonify({"error": f"AI Provider Error: {response.text}"}), response.status_code

        result = response.json()
        reply = result['choices'][0]['message']['content']
        logging.info("Successfully generated LifeOS response")
        return jsonify({"reply": reply.strip()})

    except Exception as e:
        logging.exception("Unexpected error")
        return jsonify({"error": str(e)}), 500


# -------------------- /chat Endpoint --------------------
@app.route("/chat", methods=["POST"])
def chat():
    logging.info("Received request to /chat endpoint")
    data = request.json
    user_name = data.get("name", "User")
    user_goals = data.get("goals", "general personal development")
    user_activities = data.get("activities", [])
    user_message = data.get("message", "")

    if not user_message:
        logging.warning("No user message provided")
        return jsonify({"error": "No message provided"}), 400

    # Explicitly directing the AI to avoid JSON in the prompt itself
    personalization_prompt = f"""
    Personalize this reply for {user_name}. 
    Goals: {user_goals}. 
    Recent Activities: {', '.join(user_activities) if user_activities else 'none'}.
    
    Task: Respond to the user's message below in plain text. Use bold headers and bullets for structure. 
    Do not use JSON formatting.
    
    User says: {user_message}
    """

    payload = {
        "model": HF_MODEL,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": personalization_prompt}
        ], # Added missing bracket/comma here
        "max_tokens": 500,
        "temperature": 0.7
    }

    headers = {
        "Authorization": f"Bearer {HF_TOKEN}",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(HF_API_URL, headers=headers, json=payload, timeout=60)
        if response.status_code != 200:
            logging.error(f"Router Error {response.status_code}: {response.text}")
            return jsonify({"error": f"AI Provider Error: {response.text}"}), response.status_code

        result = response.json()
        reply = result['choices'][0]['message']['content']
        logging.info(f"Successfully generated personalized chat reply for {user_name}")
        return jsonify({"reply": reply.strip()})

    except Exception as e:
        logging.exception("Unexpected error in /chat")
        return jsonify({"error": str(e)}), 500


# -------------------- Main --------------------
if __name__ == "__main__":
    # Render and other cloud platforms provide the PORT environment variable
    port = int(os.environ.get("PORT", 5001))
    logging.info(f"LifeOS AI server starting on port {port}...")
    app.run(host="0.0.0.0", port=port, debug=False) # Debug False for production