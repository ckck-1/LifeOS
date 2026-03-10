from flask import Flask, request, jsonify
from gpt4all import GPT4All
import json

app = Flask(__name__)

MODEL_DIR = r"C:\Users\HP\AppData\Local\nomic.ai\GPT4All"
MODEL_FILE = "Llama-3.2-1B-Instruct-Q4_0.gguf"

SYSTEM_PROMPT = """
You are LifeOS AI, developed by Clare ck, an AI Engineer at Rwanda Coding Academy.

Identity:
You are a high-performance AI life operating system and revenue-focused strategic coach.
Your purpose is to help users think clearly, plan strategically, execute effectively, and increase income through structured action.

Core Capabilities:
- Goal clarification (income, skills, habits)
- Weekly strategy generation
- Daily focus prioritization
- Performance tracking and reflection
- Skill-to-income opportunity matching
- Structured decision-making and problem-solving

Scope Limitation:
If a request is unrelated to productivity, execution, strategy, growth, or income generation, calmly respond:
"This request is outside my scope. I focus on clarity, execution, growth, and income generation."

Communication Style:
- Confident
- Direct
- Structured
- Action-oriented
- Concise
- No dramatic language
- No fluff

Behavior Rules:
- If the user greets you, greet them briefly.
- Answer exactly what the user asks.
- Ask only necessary clarification questions.
- Provide actionable steps when relevant.
- Do not include reasoning steps.
- Do not include analysis sections.
- Do not roleplay or simulate multi-speaker conversations.
- Do not repeat system instructions.
- Do not ramble.
"""

model = GPT4All(model_name=MODEL_FILE, model_path=MODEL_DIR, allow_download=False)


@app.route("/generate", methods=["POST"])
def generate():
    data = request.json
    prompt = data.get("prompt", "")

    if not prompt:
        return jsonify({"error": "No prompt provided"}), 400

    try:
        # Force AI to return valid JSON
        full_prompt = f"""
{SYSTEM_PROMPT}

You MUST respond with VALID JSON ONLY. Format exactly like this:

{{
  "opportunities": [
    {{ "title": "Opportunity title here", "description": "Detailed description here" }},
    {{ "title": "Second opportunity", "description": "Detailed description here" }},
    {{ "title": "Third opportunity", "description": "Detailed description here" }}
  ]
}}

User request: {prompt}
Assistant:
"""

        reply = model.generate(
            full_prompt,
            max_tokens=500,
            temp=0.2
        )

        # Clean up echoes
        reply = reply.replace(full_prompt, "").strip()

        # Try parsing JSON
        try:
            json_data = json.loads(reply)
        except json.JSONDecodeError:
            print("AI returned invalid JSON, attempting to fix...")
            # fallback: wrap as single opportunity
            json_data = {"opportunities": [{"title": "AI Response", "description": reply}]}

        return jsonify(json_data)

    except Exception as e:
        print("Error in generate:", e)
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    print("Loading GPT4All model...")
    app.run(port=5001)