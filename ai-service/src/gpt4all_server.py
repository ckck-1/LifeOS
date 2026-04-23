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

# --- HuggingFace Router Config ---
HF_API_URL = "https://router.huggingface.co/v1/chat/completions"
HF_TOKEN = os.getenv("HF_API_TOKEN")
HF_MODEL = "Qwen/Qwen2.5-7B-Instruct"

# -------------------- SYSTEM PROMPT --------------------
SYSTEM_PROMPT = """
You are LifeOS AI — a premium, intelligent life operating system and strategic coach.

Brand personality:
- Calm, focused, futuristic, and intentional
- Minimal, high-trust, and practical
- Think like a high-performance assistant, not a chatbot

Core behavior:
- Respond in clear, natural plain text only
- Start directly with the answer
- No headings, labels, or sections
- No JSON, code blocks, or structured formatting
- Use bullets only if they improve clarity
- Keep responses concise unless depth is required
- Be direct, useful, and actionable

LifeOS thinking:
- Focus on clarity, execution, and momentum
- Help the user move forward, not just reflect
- Prioritize goals, discipline, and real progress
- Give practical next steps when useful

Tone control:
- Calm if user feels stuck
- Sharp if user is unfocused
- Encouraging if user is progressing

Rules:
- Never say "Hello User"
- Never act generic
- Never explain your behavior
- Never mention being an AI
"""

# -------------------- HELPER: CALL AI --------------------
def call_ai(messages):
    payload = {
        "model": HF_MODEL,
        "messages": messages,
        "max_tokens": 500,
        "temperature": 0.7
    }

    headers = {
        "Authorization": f"Bearer {HF_TOKEN}",
        "Content-Type": "application/json"
    }

    response = requests.post(HF_API_URL, headers=headers, json=payload, timeout=60)

    if response.status_code != 200:
        logging.error(f"Router Error {response.status_code}: {response.text}")
        return None, response.text

    result = response.json()
    reply = result['choices'][0]['message']['content']
    return reply.strip(), None


# -------------------- /generate --------------------
@app.route("/generate", methods=["POST"])
def generate():
    logging.info("Received request to /generate")

    data = request.json
    user_prompt = str(data.get("prompt", "")).strip()

    if not user_prompt:
        return jsonify({"error": "Prompt is required"}), 400

    reply, error = call_ai([
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": user_prompt}
    ])

    if error:
        return jsonify({"error": error}), 500

    return jsonify({"reply": reply})


# -------------------- /chat --------------------
@app.route("/chat", methods=["POST"])
def chat():
    logging.info("Received request to /chat")

    data = request.json

    user_name = data.get("name")
    user_goals = data.get("goals", "general personal development")
    user_activities = data.get("activities", [])
    user_message = str(data.get("message", "")).strip()

    # 🔥 NEW: conversation history from Node
    history = data.get("history", [])

    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    # --- Name handling ---
    if user_name and user_name.strip():
        name_instruction = f"The user's name is {user_name.strip()}. Use it naturally once in conversation."
    else:
        name_instruction = "Do not assume or use any name."

    # --- System message (your personality stays same) ---
    messages = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT + f"""

{name_instruction}
User goals: {user_goals}
Recent activity: {', '.join(user_activities) if user_activities else 'none'}
"""
        }
    ]

    # 🔥 NEW: inject conversation memory
    for msg in history:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        if content:
            messages.append({
                "role": role,
                "content": content
            })

    # 🔥 current message goes last
    messages.append({
        "role": "user",
        "content": user_message
    })

    # --- Call AI ---
    reply, error = call_ai(messages)

    if error:
        return jsonify({"error": error}), 500

    return jsonify({"reply": reply})

# -------------------- MAIN --------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    logging.info(f"LifeOS AI server running on port {port}")
    app.run(host="0.0.0.0", port=port, debug=False)