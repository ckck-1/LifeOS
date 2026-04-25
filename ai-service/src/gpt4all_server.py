from flask import Flask, request, jsonify
import os, requests, logging
from dotenv import load_dotenv
from datetime import datetime

# Load environment variables
load_dotenv()
app = Flask(__name__)

# --- Configure Logging ---
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[logging.StreamHandler()]
)

# --- Simple in-memory cache (replace with DB later) ---
daily_focus_cache = {}

# --- Mistral AI Config ---
MISTRAL_API_URL = "https://api.mistral.ai/v1/chat/completions"
MISTRAL_TOKEN = os.getenv("MISTRAL_API_KEY")
MISTRAL_MODEL = "mistral-large-latest"

# =========================
# SYSTEM PROMPT (DAILY FOCUS)
# =========================
SYSTEM_PROMPT_DAILY = """
You are LifeOS AI — a precision execution system.

Your job:
Generate today's focus.

Strict rules:
- Maximum 2 sentences ONLY
- Short and actionable
- No explanations
- No greetings
- No formatting
- No extra text

Focus rules:
- Prioritize highest impact actions
- Use user's tasks as context
"""

# =========================
# SYSTEM PROMPTS (UNCHANGED)
# =========================
SYSTEM_PROMPT_GENERATE = """..."""  # keep yours
SYSTEM_PROMPT_CHAT = """..."""      # keep yours


# -------------------- HELPER: CALL AI --------------------
def call_ai(messages):
    payload = {
        "model": MISTRAL_MODEL,
        "messages": messages,
        "max_tokens": 200,
        "temperature": 0.6
    }

    headers = {
        "Authorization": f"Bearer {MISTRAL_TOKEN}",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(
            MISTRAL_API_URL,
            headers=headers,
            json=payload,
            timeout=60
        )

        if response.status_code != 200:
            logging.error(f"Mistral Error {response.status_code}: {response.text}")
            return None, response.text

        result = response.json()

        reply = (
            result.get("choices", [{}])[0]
            .get("message", {})
            .get("content", "")
        )

        return reply.strip(), None

    except Exception as e:
        logging.error(f"Mistral Exception: {str(e)}")
        return None, str(e)


# -------------------- /daily-focus --------------------
@app.route("/daily-focus", methods=["POST"])
def daily_focus():
    try:
        data = request.json

        user_id = str(data.get("userId"))
        user_tasks = data.get("tasks", [])
        user_goals = data.get("goals", "general productivity")

        if not user_id:
            return jsonify({"error": "userId is required"}), 400

        # Normalize today's date
        today = datetime.utcnow().date()

        # 1. Check cache
        if user_id in daily_focus_cache:
            cached = daily_focus_cache[user_id]

            if cached["date"] == today:
                return jsonify({
                    "success": True,
                    "response": cached["text"],
                    "cached": True
                })

        # 2. Generate from AI
        prompt = f"""
Generate today's focus.

User goals: {user_goals}
Tasks: {user_tasks}
"""

        reply, error = call_ai([
            {"role": "system", "content": SYSTEM_PROMPT_DAILY},
            {"role": "user", "content": prompt}
        ])

        if error or not reply:
            return jsonify({"success": False, "message": "AI generation failed"}), 500

        # 🔒 Enforce max 2 lines backend-side
        lines = reply.split("\n")
        trimmed = "\n".join(lines[:2])

        # 3. Save to cache
        daily_focus_cache[user_id] = {
            "date": today,
            "text": trimmed
        }

        return jsonify({
            "success": True,
            "response": trimmed,
            "cached": False
        })

    except Exception as err:
        return jsonify({"success": False, "message": str(err)}), 500


# -------------------- /generate --------------------
@app.route("/generate", methods=["POST"])
def generate():
    data = request.json
    user_prompt = str(data.get("prompt", "")).strip()

    if not user_prompt:
        return jsonify({"error": "Prompt is required"}), 400

    reply, error = call_ai([
        {"role": "system", "content": SYSTEM_PROMPT_GENERATE},
        {"role": "user", "content": user_prompt}
    ])

    if error:
        return jsonify({"error": error}), 500

    return jsonify({"reply": reply})


# -------------------- /chat --------------------
@app.route("/chat", methods=["POST"])
def chat():
    data = request.json

    user_name = data.get("name")
    user_goals = data.get("goals", "general personal development")
    user_activities = data.get("activities", [])
    user_message = str(data.get("message", "")).strip()
    history = data.get("history", [])

    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    if user_name and user_name.strip():
        name_instruction = f"The user's name is {user_name.strip()}."
    else:
        name_instruction = "Do not assume a name."

    messages = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT_CHAT + f"""

{name_instruction}
User goals: {user_goals}
Recent activity: {', '.join(user_activities) if user_activities else 'none'}
"""
        }
    ]

    for msg in history:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        if content:
            messages.append({"role": role, "content": content})

    messages.append({
        "role": "user",
        "content": user_message
    })

    reply, error = call_ai(messages)

    if error:
        return jsonify({"error": error}), 500

    return jsonify({"reply": reply})


# -------------------- MAIN --------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    logging.info(f"LifeOS AI server running on port {port}")
    app.run(host="0.0.0.0", port=port, debug=False)