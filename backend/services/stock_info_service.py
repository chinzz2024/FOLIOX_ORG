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
    print(totp)
    return totp.now()
def login_and_get_token():
    """Improved login with token validation"""
    try:
        smartApi = SmartConnect(api_key)
        totp = generate_totp(totp_token)
        
        # First login attempt
        data = smartApi.generateSession(username, pwd, totp)
        
        if not data['status']:
            # Immediate retry with new TOTP
            totp = generate_totp(totp_token)
            data = smartApi.generateSession(username, pwd, totp)
            if not data['status']:
                raise Exception(f"Login failed: {data.get('message', 'Unknown error')}")

        token = data['data']['jwtToken']
        if len(token) < 100:  # Basic token validation
            raise Exception("Invalid token length received")
            
        logger.info(f"Login successful (Token: {token[:10]}...)")
        return token
        
    except Exception as e:
        logger.error(f"Login failed: {str(e)}")
        raise Exception("Please check your credentials and try again")

def fetch_historical_data(symboltoken, fromdate, todate):
    """More robust data fetching"""
    try:
        authToken = login_and_get_token()
        
        # Verify token format
        if not authToken.startswith('eyJ'):  # JWT tokens typically start with eyJ
            raise Exception("Invalid token format")
            
        conn = http.client.HTTPSConnection("apiconnect.angelone.in")
        payload = json.dumps({
            "exchange": "NSE",
            "symboltoken": symboltoken,
            "interval": "ONE_MINUTE",  # More reliable interval
            "fromdate": fromdate,
            "todate": todate
        })
        
        headers = {
            'Authorization': f'Bearer {authToken}',
            'X-PrivateKey': api_key,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-SourceID': 'WEB',
            'X-UserType': 'USER'
        }
        
        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)
        res = conn.getresponse()
        
        if res.status != 200:
            raise Exception(f"API Error {res.status}: {res.reason}")
            
        data = json.loads(res.read().decode())
        if not data.get('data'):
            raise Exception("No data in response")
            
        return data
        
    except Exception as e:
        logger.error(f"API Call Failed: {str(e)}")
        return None