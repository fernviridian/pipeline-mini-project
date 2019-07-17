from flask import Flask
from flask import jsonify
import time
import socket

app = Flask(__name__)

@app.route("/")
def info():
    return socket.gethostname()

@app.route("/time")
def automation_time():
    body = {
        "message": "Automation for the People",
        "timestamp": int(time.time())
    }
    return jsonify(body)
