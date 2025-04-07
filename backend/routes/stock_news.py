from flask import Blueprint, jsonify, request
from services.stock_service import NewsScraper
import asyncio

stock_news_bp = Blueprint('stock_news', __name__)

@stock_news_bp.route('/stock-news', methods=['GET'])
def stock_news():
    try:
        scraper = NewsScraper()
        news = asyncio.run(scraper.get_news())
        
        if not news:  # Explicit check for empty data
            return jsonify({
                'status': 404,
                'message': 'No news found (login or scraping may have failed)',
                'data': []
            }), 404

        # ... rest of your pagination logic ...
        
    except Exception as e:
        import traceback
        traceback.print_exc()  # Log full error to console
        return jsonify({
            'status': 500,
            'message': str(e),  # Send actual error to frontend
            'data': []
        }), 500