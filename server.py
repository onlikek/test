from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/ping", methods=["POST"])
def ping():
    data = request.get_json()
    message = data.get("message") if data else None  # читаем сообщение

    if message.lower() == "hello":
        reply = "World!"
    else:
        reply = "неверное слово"

    return jsonify({"reply": reply})

if __name__ == "__main__":
    app.run(port=5000)
