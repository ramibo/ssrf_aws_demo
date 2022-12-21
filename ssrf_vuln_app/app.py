from flask import *
import requests

app = Flask(__name__)

@app.route("/")
def home():
    return "AWS SSRF IMDSv1 demo"

@app.route('/uptime')
def url():
    url = request.args.get('url', '')
    valid_url = quote(url, safe='/:?&')
    if valid_url:
        content = requests.get(valid_url).text
        return (content)

    return "Please provide an url"