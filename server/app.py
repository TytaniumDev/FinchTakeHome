from flask import Flask
import os
from server.routes import bp

app = Flask(__name__)
app.register_blueprint(bp)

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
