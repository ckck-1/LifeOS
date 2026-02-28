from flask import Flask, request, jsonify
from gpt4all import GPT4All

app = Flask(__name__)

MODEL_DIR = r"C:\Users\HP\AppData\Local\nomic.ai\GPT4All"
MODEL_FILE = "Llama-3.2-1B-Instruct-Q4_0.gguf"

# Load the model
model = GPT4All(model_name=MODEL_FILE, model_path=MODEL_DIR, allow_download=False)

@app.route("/chat", methods=["POST"])
def chat():
    data = request.json
    message = data.get("message")

    if not message:
        return jsonify({"error": "No message provided"}), 400

    try:
        # Create a chat session per request
        with model.chat_session() as session:
            # Use session.generate() instead of session.prompt()
            reply = session.generate(
                message,
                max_tokens=150,
                temp=0.7,
                top_p=0.9
            )
        return jsonify({"reply": reply})
    except Exception as e:
        print("Error in chat:", e)
        return jsonify({"error": str(e)}), 500


@app.route("/generate", methods=["POST"])
def generate():
    data = request.json
    prompt = data.get("prompt", "")

    if not prompt:
        return jsonify({"error": "No prompt provided"}), 400

    try:
        reply = model.generate(
            prompt,
            max_tokens=500,
            temp=0.7
        )
        return jsonify({"reply": reply})
    except Exception as e:
        print("Error in generate:", e)
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    print("Loading GPT4All model...")
    app.run(port=5001)