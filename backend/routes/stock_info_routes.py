from flask import Blueprint, request, jsonify
from services.stock_info_service import login, fetch_historical_data

stock_info_bp = Blueprint('stock_info_bp', __name__)

# Login route
@stock_info_bp.route('/login', methods=['POST'])
def login_route():
    try:
        totp_token = request.json.get('totp_token')
        if not totp_token:
            return jsonify({"status": False, "message": "TOTP token is required"}), 400

        authToken, refreshToken = login(totp_token)

        return jsonify({
            "status": True,
            "authToken": authToken,
            "refreshToken": refreshToken
        })

    except Exception as e:
        return jsonify({"status": False, "message": str(e)}), 500

# Fetch historical stock data
@stock_info_bp.route('/fetch_historical_data', methods=['POST'])
def fetch_historical_data_route():
    try:
        authToken = request.json.get('authToken')
        symboltoken = request.json.get('symboltoken')
        fromdate = request.json.get('fromdate')
        todate = request.json.get('todate')

        if not authToken or not symboltoken or not fromdate or not todate:
            return jsonify({"status": False, "message": "All fields are required"}), 400

        hist = fetch_historical_data(authToken, symboltoken, fromdate, todate)

        return jsonify({"status": True, "data": hist})

    except Exception as e:
        return jsonify({"status": False, "message": str(e)}), 500
