from flask import Blueprint, jsonify
from services.loan_scraper import scrape_loan_rates

loan_routes_bp = Blueprint('loan_routes', __name__)

@loan_routes_bp.route('/loan-rates', methods=['GET'])
def loan_rates():
    try:
        loan_rates = scrape_loan_rates()
        return jsonify(loan_rates), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
