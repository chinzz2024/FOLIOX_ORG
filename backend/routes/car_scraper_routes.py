from flask import Blueprint, request, jsonify
from services.car_scraper import scrape_cartrade

car_scraper_bp = Blueprint('car_scraper', __name__)

@car_scraper_bp.route('/api/cars', methods=['GET'])
def get_cars():
    max_price = request.args.get('max_price', type=float)
    if max_price is None:
        return jsonify({"error": "Please provide a valid max_price parameter."}), 400

    try:
        cars = scrape_cartrade(max_price)
        if isinstance(cars, dict) and "error" in cars:
            return jsonify({"error": cars["error"]}), 500
        return jsonify({"cars": cars})
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {str(e)}"}), 500
