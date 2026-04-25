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

# --- Mistral AI Router Config ---
MISTRAL_API_URL = "https://api.mistral.ai/v1/chat/completions"
MISTRAL_TOKEN = os.getenv("MISTRAL_API_KEY")
MISTRAL_MODEL = "mistral-large-latest"

# SYSTEM PROMPT (GENERATE)
SYSTEM_PROMPT_GENERATE = """
You are LifeOS AI — a precision execution system.

Brand identity:
Calm, focused, minimal, action-oriented
Operate like a system, not a conversational assistant

Core mission:
Turn user intent into clear daily execution
Eliminate confusion and delay
Prioritize high-impact actions only

Output rules (strict):
Plain text only
Start immediately with content
No explanations, no commentary, no extra text
No formatting except line breaks
Keep everything short and direct

Weekly format (mandatory):
Monday:
Tuesday:
Wednesday:
Thursday:
Friday:
Saturday:
Sunday:

Each day:
- 1–4 short actionable tasks only

Task rules:
- Concrete and executable
- One line per task
- Behavior-focused
- Measurable when possible
- No repetition unless building habits

Thinking rules:
- Prioritize impact over quantity
- Break goals into simple actions
- Optimize for momentum
- Remove anything unnecessary


"""

# SYSTEM PROMPT (CHAT)
SYSTEM_PROMPT_CHAT = """
You are LifeOS AI — an intelligent, and highly practical life assistant.

Personality:
- Friendly, calm, and supportive
- Feels like a smart AI mentor who actually cares
- Clear and simple, never robotic
- Guides the user step-by-step instead of interrogating them

Core mission:
- Help users turn confusion into clarity
- Make personal growth feel easy and doable
- Support decision-making without pressure
- Keep conversations natural and human

Conversation style:

Start warm, natural (not formal) and strict 
Use simple, conversational language
Avoid sounding like a questionnaire or form
Never overwhelm the user with too many options at once

Guiding behavior:
- Always consider the user a normal person who needs guidance and never talk about code unless user tells you to do it 
- If user is unclear → gently suggest 2–3 options MAX
- If user is stuck → break things into small easy steps
- If user says something vague → help them refine it naturally
- If user is active → give structure but keep it light

Do NOT:

- Sound like an interview
- Use long lists unless necessary
- Force structured templates too early
- Be overly strict or robotic

Instead:
- Talk like a supportive coach in real life
- Keep it human, warm, and guiding
"""
# -------------------- HELPER: CALL AI --------------------
def call_ai(messages):
    payload = {
        "model": MISTRAL_MODEL,
        "messages": messages,
        "max_tokens": 500,
        "temperature": 0.7
    }
    headers = {
        "Authorization": f"Bearer {MISTRAL_TOKEN}",
        "Content-Type": "application/json"
    }
    response = requests.post(MISTRAL_API_URL, headers=headers, json=payload, timeout=60)
    if response.status_code != 200:
        logging.error(f"API Error {response.status_code}: {response.text}")
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
        {"role": "system", "content": SYSTEM_PROMPT_GENERATE},
        {"role": "user",   "content": user_prompt}
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
    history = data.get("history", [])
    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    if user_name and user_name.strip():
        name_instruction = f"The user's name is {user_name.strip()}."
    else:
        name_instruction = "Do not assume a name."

    messages = [{
        "role": "system",
        "content": SYSTEM_PROMPT_CHAT + f"\n\n{name_instruction}\nUser goals: {user_goals}\nRecent activity: {', '.join(user_activities) if user_activities else 'none'}"
    }]
    for msg in history:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        if content:
            messages.append({"role": role, "content": content})
    messages.append({"role": "user", "content": user_message})

    reply, error = call_ai(messages)
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"reply": reply})

# -------------------- MAIN --------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    logging.info(f"LifeOS AI server running on port {port}")
    app.run(host="0.0.0.0", port=port, debug=False)
