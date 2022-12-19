from flask import *
import requests

app = Flask(__name__)

@app.route("/")
def home():
    return "AWS SSRF IMDSv1 demo"

@app.route('/uptime')
def url():
    url = request.args.get('url', '')
    if url:
        content = requests.get(url).text
        return (content)

    return "Please provide an url"