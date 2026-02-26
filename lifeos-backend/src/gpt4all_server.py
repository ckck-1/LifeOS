from flask import Flask, request, jsonify
from gpt4all import GPT4All
import os

app = Flask(__name__)

MODEL_DIR = r"C:\Users\HP\AppData\Local\nomic.ai\GPT4All"
MODEL_FILE = "qwen2-1_5b-instruct-q4_0.gguf"

model = GPT4All(
    model_name=MODEL_FILE,
    model_path=MODEL_DIR,
    allow_download=False
)

@app.route("/generate", methods=["POST"])
def generate():
    data = request.json
    prompt = data.get("prompt", "")

    with model.chat_session():
        response = model.generate(
            prompt,
            max_tokens=500,
            temp=0.7,
        )

    return jsonify({"text": response})

if __name__ == "__main__":
    print("Loading  quen model...")
    app.run(port=5001)