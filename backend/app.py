from flask import Flask
from flask_cors import CORS
from routes.stock_news import stock_news_bp

app = Flask(__name__)

# Enable CORS for all routes
CORS(app)

# Register the stock news route
app.register_blueprint(stock_news_bp)

if __name__ == '__main__':
    app.run(debug=True)
