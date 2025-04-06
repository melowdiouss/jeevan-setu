from flask import Flask, request, jsonify
from transformers import T5Tokenizer, T5ForConditionalGeneration

app = Flask(__name__)

# Load the T5 model and tokenizer
model_name = "t5-small"  # You can change to "t5-base" or "t5-large" for better results
tokenizer = T5Tokenizer.from_pretrained(model_name)
model = T5ForConditionalGeneration.from_pretrained(model_name)

@app.route('/process_text', methods=['POST'])
def process_text():
    data = request.json  # Get JSON input
    text = data.get("text", "")

    if not text:
        return jsonify({"error": "No text provided"}), 400

    # Convert input to T5 format (e.g., Summarization)
    input_ids = tokenizer.encode("summarize: " + text, return_tensors="pt", max_length=512, truncation=True)
    output_ids = model.generate(input_ids, max_length=100, num_beams=2)
    result = tokenizer.decode(output_ids[0], skip_special_tokens=True)

    return jsonify({"output": result})  # Return response as JSON

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)