from flask import Blueprint, request, jsonify
import razorpay
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Create Blueprint
payment_routes_bp = Blueprint('payment_routes', __name__)

# Initialize Razorpay client
razorpay_client = razorpay.Client(
    auth=(os.getenv('RAZORPAY_KEY_ID'), os.getenv('RAZORPAY_KEY_SECRET'))
)

@payment_routes_bp.route('/create-razorpay-order', methods=['POST'])
def create_razorpay_order():
    try:
        data = request.get_json()
        
        # Validate required fields
        if not all(key in data for key in ['amount', 'currency', 'receipt']):
            return jsonify({
                'status': False,
                'message': 'Missing required fields'
            }), 400
        
        # Amount should be in paise (multiply by 100)
        amount_in_paise = int(float(data['amount']) * 100)
        
        # Create Razorpay order
        order_data = {
            'amount': amount_in_paise,
            'currency': data['currency'],
            'receipt': data['receipt'],
            'notes': data.get('notes', {})
        }
        
        order = razorpay_client.order.create(data=order_data)
        
        return jsonify({
            'status': True,
            'id': order['id'],
            'amount': order['amount'],
            'currency': order['currency'],
            'receipt': order['receipt'],
            'notes': order.get('notes', {})
        })
        
    except Exception as e:
        print(f"Error creating Razorpay order: {str(e)}")
        return jsonify({
            'status': False,
            'message': str(e)
        }), 500

@payment_routes_bp.route('/get-order-details/<order_id>', methods=['GET'])
def get_order_details(order_id):
    try:
        # Fetch order details from Razorpay
        order = razorpay_client.order.fetch(order_id)
        
        # You can add additional verification here if needed
        
        return jsonify({
            'status': True,
            'id': order['id'],
            'amount': order['amount'],
            'currency': order['currency'],
            'receipt': order['receipt'],
            'notes': order.get('notes', {})
        })
        
    except Exception as e:
        print(f"Error fetching order details: {str(e)}")
        return jsonify({
            'status': False,
            'message': str(e)
        }), 500

@payment_routes_bp.route('/verify-payment', methods=['POST'])
def verify_payment():
    try:
        data = request.get_json()
        
        # Required fields for verification
        params_dict = {
            'razorpay_order_id': data.get('razorpay_order_id'),
            'razorpay_payment_id': data.get('razorpay_payment_id'),
            'razorpay_signature': data.get('razorpay_signature')
        }
        
        # Verify the payment signature
        razorpay_client.utility.verify_payment_signature(params_dict)
        
        return jsonify({
            'status': True,
            'message': 'Payment verified successfully'
        })
        
    except Exception as e:
        print(f"Payment verification failed: {str(e)}")
        return jsonify({
            'status': False, 
            'message': str(e)
        }), 400