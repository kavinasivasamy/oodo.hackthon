from flask import Flask
from flask_cors import CORS

app = Flask(__name__)

CORS(app)

app.config["SECRET_KEY"] = "dayflow_secret_key_2026"


@app.route("/")
def home():
    return {
        "message": "Dayflow HRMS Backend is running",
        "status": "success"
    }


if __name__ == "__main__":
    app.run(debug=True)