from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return {
        "application": "aws-devops-platform",
        "environment": "dev",
        "status": "healthy",
        "version": "v1"
    }

@app.route("/health")
def health():
    return {"status": "healthy"}, 200
