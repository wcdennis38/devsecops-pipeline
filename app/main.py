import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return {"message": "DevSecOps app is running"}

# Optional health endpoint (good for Docker/CI)
@app.route("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8080))

    app.run(host=HOST, port=PORT)
