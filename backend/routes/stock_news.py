from flask import Blueprint, jsonify, request
from services.stock_service import get_cached_news

stock_news_bp = Blueprint('stock_news', __name__)

@stock_news_bp.route('/stock-news', methods=['GET'])
def get_stock_news():
    try:
        # Get pagination parameters
        page = int(request.args.get('page', 1))
        per_page = int(request.args.get('per_page', 20))
        
        # Get all news (cached or fresh)
        all_news = get_cached_news()
        
        # Apply pagination
        start = (page - 1) * per_page
        end = start + per_page
        paginated_news = all_news[start:end]
        
        return jsonify({
            'news': paginated_news,
            'total': len(all_news),
            'page': page,
            'per_page': per_page,
            'has_more': end < len(all_news)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500