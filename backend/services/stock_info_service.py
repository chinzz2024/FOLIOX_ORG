import http.client
import json
import logging
from datetime import datetime
from SmartApi import SmartConnect

# Logger setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Replace these with your actual credentials
api_key = "your_api_key"
username = "your_username"
pwd = "your_pwd"
totp_token = "your_totp_token"

def generate_totp(secret):
    """Generate a TOTP token using the secret."""
    from pyotp import TOTP
    totp = TOTP(secret)
    print(totp)
    return totp.now()

def login_and_get_token():
    """Logs in and returns auth token."""
    try:
        smartApi = SmartConnect(api_key)
        totp = generate_totp(totp_token)
        data = smartApi.generateSession(username, pwd, totp)

        if not data['status']:
            raise Exception(f"Login failed: {data}")

        logger.info("Login successful")
        return data['data']['jwtToken']
    except Exception as e:
        logger.error(f"Login failed: {e}")
        raise e

def fetch_historical_data(symboltoken, fromdate, todate):
    """Fetches historical data after automatic login."""
    try:
        authToken = login_and_get_token()  # Automatically log in and get token
        historicParam = {
            "exchange": "NSE",
            "symboltoken": symboltoken,
            "interval": "FIFTEEN_MINUTE",
            "fromdate": fromdate,
            "todate": todate,
        }
        conn = http.client.HTTPSConnection("apiconnect.angelone.in")
        payload = json.dumps(historicParam)
        headers = {
            'Authorization': f' {authToken}',  # Pass the authToken here
            'X-PrivateKey': 'VJ5iztNm',                # Replace with your actual API Key
            'Accept': 'application/json',
            'X-SourceID': 'WEB',
            'X-ClientLocalIP': '127.0.0.1',           # Replace with actual IP
            'X-ClientPublicIP': '106.193.147.98',     # Replace with actual IP
            'X-MACAddress': '74:12:b3:c5:f6:76',      # Replace with actual MAC address
            'X-UserType': 'USER',
            'Content-Type': 'application/json'
        }
        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)
        res = conn.getresponse()
        data = res.read().decode()

        # Print and log the response received from the backend
        print("Raw Data Fetched:", data)
        logger.info(f"Raw Data Fetched: {data}")

        logger.info("Historical data fetched successfully")
        return json.loads(data)
    except Exception as e:
        logger.exception(f"Error fetching historical data: {e}")
        return None