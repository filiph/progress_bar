import os
from flask import Flask, redirect

app = Flask(__name__)

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def redirect_to_vps(path):
    # Redirect all traffic from old GAE app to the new VPS URL
    return redirect('https://progress.filiph.net', code=301)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=int(os.environ.get('PORT', 8080)), debug=True)
