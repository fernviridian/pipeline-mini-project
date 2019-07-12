from flask import Flask
from flask import jsonify
import time

app = Flask(__name__)


@app.route("/time")
def automation_time():
    body = {
        "message": "Automation for the People",
        "timestamp": int(time.time())
    }
    return jsonify(body)
