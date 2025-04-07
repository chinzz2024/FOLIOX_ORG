from flask import Blueprint, jsonify, request
from services.stock_service import NewsScraper
import asyncio

stock_news_bp = Blueprint('stock_news', __name__)

@stock_news_bp.route('/stock-news', methods=['GET'])
def stock_news():
    try:
        # Get pagination params
        page = max(1, int(request.args.get('page', 1)))
        per_page = min(20, max(5, int(request.args.get('per_page', 10))))
        
        # Get news
        scraper = NewsScraper()
        all_news = asyncio.run(scraper.get_news())
        
        # Paginate
        total = len(all_news)
        paginated = all_news[(page-1)*per_page : page*per_page]
        
        return jsonify({
            'status': 200,
            'data': paginated,
            'meta': {
                'total': total,
                'page': page,
                'per_page': per_page,
                'has_more': (page*per_page) < total
            }
        })
        
    except Exception as e:
        return jsonify({
            'status': 500,
            'message': f"Failed to fetch news: {str(e)}",
            'data': []
        }), 500