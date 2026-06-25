from flask import Flask, jsonify
import os

app = Flask(__name__)

# =========================
# SECURITY CONFIG
# =========================

secret_key = os.getenv("FLASK_APP_KEY")

if not secret_key:
    raise RuntimeError("FLASK_APP_KEY environment variable is required")

app.config["SECRET_KEY"] = secret_key


# =========================
# ROUTES
# =========================

@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "ok",
        "message": "DevSecOps Pipeline Running in AWS!"
    }), 200


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy"
    }), 200


# =========================
# ENTRYPOINT
# =========================

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=8080,
        debug=False
    )
