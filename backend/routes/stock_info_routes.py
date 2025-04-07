from flask import Blueprint, request, jsonify
from services.stock_info_service import fetch_historical_data

stock_info_bp = Blueprint('stock_info', __name__)

@stock_info_bp.route('/fetch_historical_data', methods=['POST'])
def fetch_historical_data_route():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": False, "message": "Request body must be JSON"}), 400

        required = {'symboltoken', 'fromdate', 'todate'}
        if not required.issubset(data.keys()):
            return jsonify({
                "status": False,
                "message": "Missing required fields",
                "required": list(required)
            }), 400

        result = fetch_historical_data(
            str(data['symboltoken']),  # Ensure string type
            data['fromdate'],
            data['todate']
        )

        return jsonify({
            "status": True,
            "data": result
        }), 200

    except ValueError as e:
        return jsonify({
            "status": False,
            "message": f"Validation error: {str(e)}",
            "type": "VALIDATION"
        }), 400
    except Exception as e:
        logger.exception("API Error")
        return jsonify({
            "status": False,
            "message": str(e),
            "type": "SERVER_ERROR"
        }), 500