import os
from flask import Flask
<<<<<<< Updated upstream
from flask_wtf.csrf import CSRFProtect

app = Flask(__name__)

# Read Flask secret strictly from environment
SECRET_KEY = os.getenv("FLASK_APP_KEY")
if not SECRET_KEY:
    raise RuntimeError("Missing required environment variable: FLASK_APP_KEY")

app.config.update(
    SECRET_KEY=SECRET_KEY
)

# Enable CSRF protection
csrf = CSRFProtect(app)


@app.route("/")
def home():
    return {"message": "DevSecOps Pipeline Running in AWS!"}


@app.route("/health")
def health():
    return {"status": "healthy"}
=======

app = Flask(__name__)

@app.route("/")
def home():
    return {"message": "DevSecOps app is running"}
>>>>>>> Stashed changes

# Optional health endpoint (good for Docker/CI)
@app.route("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8080))

    app.run(host=HOST, port=PORT)
