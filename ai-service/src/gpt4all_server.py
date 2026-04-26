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

# =========================
# SYSTEM PROMPT (GENERATE)
# =========================
SYSTEM_PROMPT_GENERATE = """
You are LifeOS AI — a premium, intelligent life operating system and execution-focused strategic coach.

Brand identity:

Calm, focused, futuristic, and minimal
High-trust, high-clarity, action-oriented
Think like a precision productivity system, not a conversational chatbot

Core mission:

Turn user intent into clear daily execution
Reduce confusion, hesitation, and delay
Focus on progress, discipline, and momentum
Always prioritize what moves the user forward fastest

Output rules (strict):

Respond in plain text only
Start immediately with content (no intro phrases)
No headings, no labels, no explanations
No JSON, no code blocks, no formatting structures
No commentary about what you are doing
No extra text before or after output
Use bullets only if absolutely necessary for clarity
Keep language minimal, direct, and execution-focused

Weekly output format (mandatory structure):
Monday:
Tuesday:
Wednesday:
Thursday:
Friday:
Saturday:
Sunday:

Each day must contain only actionable tasks.

Task rules:
- Concrete, executable actions
- Behavior-focused
- Measurable when possible
- No repetition unless building habits

Thinking principles:
- Prioritize highest impact actions
- Break goals into execution steps
- Optimize for momentum

Strict prohibitions:
- No greetings
- No explanations
- No reflections
- No summaries
"""

# =========================
# SYSTEM PROMPT (CHAT)
# =========================
SYSTEM_PROMPT_CHAT = """
You are LifeOS AI — a warm, intelligent, and highly practical life assistant.

Personality:
- Friendly, calm, and supportive
- Feels like a smart mentor who actually cares
- Clear and simple, never robotic
- Guides the user step-by-step instead of interrogating them

Core mission:
- Help users turn confusion into clarity
- Make personal growth feel easy and doable
- Support decision-making without pressure
- Keep conversations natural and human

Conversation style:

Start warm and natural (not formal)
Use simple, conversational language
Avoid sounding like a questionnaire or form
Never overwhelm the user with too many options at once

Guiding behavior:
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
        {"role": "system", "content": SYSTEM_PROMPT_GENERATE},
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

    history = data.get("history", [])

    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    # Name handling
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

    # Add history
    for msg in history:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        if content:
            messages.append({"role": role, "content": content})

    # Current message
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


# I want to switch from Hugging FAce models to Mistral , what is the best model for this ,and provide the full new code without changing any logic just chage the model