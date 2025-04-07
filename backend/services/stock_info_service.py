import http.client
import json
import logging
from datetime import datetime
from SmartApi import SmartConnect

# Logger setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Replace these with your actual credentials
api_key = "VJ5iztNm"
username = "AAAF841327"
pwd = "2504"
totp_token = "VKEN7FGDBEOFPJDNUYMU5GQ3DY"

def generate_totp(secret):
    """Generate a TOTP token using the secret."""
    from pyotp import TOTP
    totp = TOTP(secret)
    print("HI"totp)
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
        authToken = login_and_get_token()
        print(f"Token length: {len(authToken) if authToken else 0}")
        
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
            'Authorization': f'Bearer {authToken}',  # Added 'Bearer' prefix
            'X-PrivateKey': 'VJ5iztNm',
            'Accept': 'application/json',
            'X-SourceID': 'WEB',
            'X-ClientLocalIP': '0.0.0.0',
            'X-ClientPublicIP': '106.193.147.98',  # Uncommented
            'X-MACAddress': '74:12:b3:c5:f6:76',    # Uncommented
            'X-UserType': 'USER',                   # Uncommented
            'Content-Type': 'application/json'
        }
        
        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)
        res = conn.getresponse()
        
        # Check response status before parsing
        status = res.status
        logger.info(f"Response status: {status}")
        
        data = res.read().decode()
        logger.info(f"Raw Data Fetched: {data}")
        
        if not data:
            logger.error("Empty response received from API")
            return None
            
        try:
            return json.loads(data)
        except json.JSONDecodeError as je:
            logger.error(f"JSON decode error: {je}")
            return None
            
    except Exception as e:
        logger.exception(f"Error fetching historical data: {e}")
        return None