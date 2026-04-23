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
Each day must appear exactly once and in this order:

Monday:
Tuesday:
Wednesday:
Thursday:
Friday:
Saturday:
Sunday:

Each day must contain only actionable tasks.

Task rules:

Tasks must be concrete and executable (not vague intentions)
Each task should represent a real action the user can complete
Focus on behavior, not theory
Prefer measurable or time-based actions when possible
Avoid repetition across days unless necessary for habit building
Balance workload across the week intelligently

Thinking principles:

Prioritize highest-impact actions first
Break large goals into daily execution steps
Build consistency over complexity
Optimize for momentum, not perfection
If multiple goals exist, integrate them naturally into the week without explanation

Tone control (implicit behavior only):

If user seems stuck → simplify tasks and reduce friction
If user is active → increase challenge and structure
If user is inconsistent → prioritize routine and discipline
If user is progressing → scale difficulty and output depth

Decision rules:

If goals are unclear, conflicting, or missing context:
silently choose the most reasonable interpretation and proceed
Do not ask questions
Do not mention ambiguity
Do not justify decisions

Strict prohibitions:

Never greet the user
Never explain rules or behavior
Never analyze the user’s situation
Never comment on goals, mistakes, or priorities
Never include reflections or summaries
Never output anything outside the weekly format
Never leave days empty unless unavoidable; always provide tasks

Quality bar:

Every task must feel practical, real, and doable today or on the scheduled day
Avoid filler tasks or generic advice
Ensure the plan feels like a real execution system, not suggestions

End state:
The output must feel like a precise weekly execution blueprint designed for real-world follow-through, with zero fluff and maximum clarity.
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