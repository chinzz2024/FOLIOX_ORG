from flask import Flask
from flask_cors import CORS
from flask_caching import Cache  # Add this import
from routes.stock_news import stock_news_bp
from routes.stock_info_routes import stock_info_bp
from routes.loan_routes import loan_routes_bp
import os

app = Flask(__name__)

# Initialize Flask-Caching
cache = Cache(app, config={
    'CACHE_TYPE': 'SimpleCache',  # Use simple in-memory caching
    'CACHE_DEFAULT_TIMEOUT': 1800  # 30 minutes cache timeout
})

# Enable CORS for all routes
CORS(app)

# Register existing routes
app.register_blueprint(stock_news_bp)
app.register_blueprint(stock_info_bp)
app.register_blueprint(loan_routes_bp)

if __name__ == '__main__':
    port = int(os.getenv("PORT", 5000))
    app.run(host="0.0.0.0", port=port)