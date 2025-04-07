from flask import Flask
from flask_cors import CORS
from extensions import cache  # Import from extensions instead
from routes.stock_news import stock_news_bp
from routes.stock_info_routes import stock_info_bp
from routes.loan_routes import loan_routes_bp
from routes.payment_routes import payment_routes_bp  # Add this line
import os

app = Flask(__name__)
# Initialize cache with app
cache.init_app(app)
# Rest of your app.py remains the same
CORS(app)
app.register_blueprint(stock_news_bp)
app.register_blueprint(stock_info_bp)
app.register_blueprint(loan_routes_bp)
app.register_blueprint(payment_routes_bp)  # Add this line

if __name__ == '__main__':
    port = int(os.getenv("PORT", 5000))
    app.run(host="0.0.0.0", port=port)