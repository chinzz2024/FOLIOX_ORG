from flask import Blueprint, jsonify, request
from services.stock_info_service import get_stock_info_by_symbol

stock_info_bp = Blueprint('stock_info', __name__)

@stock_info_bp.route('/stock-info/<symbol>', methods=['GET'])
def stock_info(symbol):
    try:
        stock_data = get_stock_info_by_symbol(symbol)
        return jsonify(stock_data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
