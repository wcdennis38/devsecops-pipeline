from flask import Flask
from flask_wtf.csrf import CSRFProtect
import os

app = Flask(__name__)

# Read Flask secret strictly from environment
SECRET_KEY = os.getenv("FLASK_APP_KEY")

if not SECRET_KEY:
    raise RuntimeError(
        "Missing required environment variable: FLASK_APP_KEY"
    )

app.config.update(
    SECRET_KEY=SECRET_KEY
)

# Enable CSRF protection
csrf = CSRFProtect(app)


@app.route("/")
def home():
    return "DevSecOps Pipeline Running in AWS!"


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=False)
