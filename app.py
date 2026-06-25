from flask import Flask
from flask_wtf.csrf import CSRFProtect
import os

app = Flask(__name__)

# SECURITY: use environment variable instead of hardcoding
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "dev-insecure-key-change-me")

# ENABLE CSRF protection
csrf = CSRFProtect(app)

@app.route("/")
def home():
    return "DevSecOps Pipeline Running in AWS!"

# ONLY for local testing (NOT production)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=False)
