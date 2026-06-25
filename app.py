from flask import Flask
from flask_wtf.csrf import CSRFProtect
import os

app = Flask(__name__)

# Read Flask secret from environment
secret_key = os.environ.get("FLASK_APP_KEY")

if not secret_key:
    raise RuntimeError("FLASK_APP_KEY environment variable is required")

app.config["SECRET_KEY"] = secret_key

# Enable CSRF protection
csrf = CSRFProtect(app)

@app.route("/")
def home():
    return "DevSecOps Pipeline Running in AWS!"

# Local development only
if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=False)
