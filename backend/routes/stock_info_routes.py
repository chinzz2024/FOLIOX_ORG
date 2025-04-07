from flask import Blueprint, request, jsonify
from services.stock_info_service import fetch_historical_data

stock_info_bp = Blueprint('stock_info', __name__)

@stock_info_bp.route('/fetch_historical_data', methods=['POST'])
def fetch_historical_data_route():
    """API route to fetch historical stock data."""
    try:
        symboltoken = request.json.get('symboltoken')
        fromdate = request.json.get('fromdate')
        todate = request.json.get('todate')

        if not symboltoken or not fromdate or not todate:
            return jsonify({"status": False, "message": "Missing fields"}), 400

        data = fetch_historical_data(symboltoken, fromdate, todate)
        if data:
            return jsonify({"status": True, "data": data}), 200
        else:
            return jsonify({"status": False, "message": "Failed to fetch data"}), 500
    except Exception as e:
        return jsonify({"status": False, "message": str(e)}), 500