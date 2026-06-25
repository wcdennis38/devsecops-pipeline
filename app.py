from flask import Flask
from flask_wtf.csrf import CSRFProtect
import os

app = Flask(__name__)

# STRICT: fail fast if secret is missing (best practice for CI/CD)
app.config["SECRET_KEY"] = os.environ["SECRET_KEY"]

csrf = CSRFProtect(app)

@app.route("/")
def home():
    return "DevSecOps Pipeline Running in AWS!"

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=False)
