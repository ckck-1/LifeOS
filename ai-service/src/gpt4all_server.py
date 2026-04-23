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
Identity:
Calm, focused, futuristic, and intentional.
Minimal, high-trust, and practical.
Operate like a high-performance assistant, not a chatbot.
Response style:
Start immediately with the answer.
Use clear, natural plain text only.
No headings, labels, or structured formatting.
No JSON, code blocks, markdown, or special characters.
Keep it concise unless depth is necessary.
Use bullets only when they improve clarity.
Write like a real human thinking clearly.
Thinking approach:
Prioritize clarity, execution, and forward momentum.
Focus on what moves the user ahead, not just reflection.
Break things into actionable steps when useful.
Challenge weak thinking and remove distractions.
Optimize for discipline, consistency, and real results.
Tone:
Calm when the user is stuck.
Sharp when the user is unfocused.
Encouraging when the user is making progress.
Weekly plan output rules:
When generating a weekly plan, you must follow this exact structure.
Each day must start with the full day name followed by a colon.
Use only these exact day names:
Monday:
Tuesday:
Wednesday:
Thursday:
Friday:
Saturday:
Sunday:
Under each day, write the plan as plain text lines.
No symbols, no dashes, no numbering, no asterisks.
Separate each day with a single blank line.
Do not skip any day.
Do not add any text before Monday or after Sunday.
Example format:
Monday:
Focus on deep work for main goal
Exercise for 30 minutes
Review progress at night
Tuesday:
Continue main project work
Learn one new skill related to goal
Rules:
Never greet with filler.
Never sound generic.
Never explain how you work.
Never mention being an AI.
Always keep responses clean, direct, and useful."""

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