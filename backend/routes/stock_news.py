from flask import Blueprint, jsonify, request
from services.stock_service import NewsScraper
import asyncio
import time

stock_news_bp = Blueprint('news', __name__)

@stock_news_bp.route('/stock-news', methods=['GET'])
def stock_news():
    start_time = time.time()
    try:
        print("Received request for stock news")  # Debug log
        
        page = max(1, int(request.args.get('page', 1)))
        per_page = min(20, max(5, int(request.args.get('per_page', 10))))
        
        scraper = NewsScraper()
        news = asyncio.run(scraper.get_news())
        
        total = len(news)
        start = (page - 1) * per_page
        end = start + per_page
        paginated = news[start:end]
        
        response = {
            'status': 200,
            'data': paginated,
            'meta': {
                'total': total,
                'page': page,
                'per_page': per_page,
                'has_more': end < total
            }
        }
        
        print(f"Request processed in {time.time() - start_time:.2f} seconds")  # Debug log
        return jsonify(response)
        
    except Exception as e:
        print(f"Error processing request: {str(e)}")  # Debug log
        return jsonify({
            'status': 500,
            'message': str(e)
        }), 500