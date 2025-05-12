from flask import Blueprint, jsonify
from services.stock_service import fetch_stock_news

stock_news_bp = Blueprint('stock_news', __name__)

@stock_news_bp.route('/stock-news', methods=['GET'])
def get_stock_news():
    stock_news = fetch_stock_news()
    return jsonify(stock_news)