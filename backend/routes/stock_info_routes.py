from flask import Blueprint, request, jsonify
from services.stock_info_service import fetch_historical_data

stock_info_bp = Blueprint('stock_info', __name__)

@stock_info_bp.route('/fetch_historical_data', methods=['POST'])
def fetch_historical_data_route():
    try:
        required_fields = ['symboltoken', 'fromdate', 'todate']
        if not all(field in request.json for field in required_fields):
            return jsonify({
                "status": False,
                "message": "Missing required fields",
                "required_fields": required_fields
            }), 400

        data = fetch_historical_data(
            request.json['symboltoken'],
            request.json['fromdate'],
            request.json['todate']
        )
        
        if not data:
            return jsonify({
                "status": False,
                "message": "No data received from broker API"
            }), 502
            
        return jsonify({
            "status": True,
            "data": data
        }), 200
        
    except Exception as e:
        logger.error(f"Route error: {str(e)}")
        return jsonify({
            "status": False,
            "message": str(e),
            "error_type": type(e).__name__
        }), 500