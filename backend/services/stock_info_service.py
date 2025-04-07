import http.client
import json
import logging
import os
from SmartApi import SmartConnect
from pyotp import TOTP

logger = logging.getLogger(__name__)

# Get credentials from environment variables
api_key = os.getenv('API_KEY', 'VJ5iztNm')
username = os.getenv('ANGELONE_USERNAME', 'AAAF841327')
pwd = os.getenv('ANGELONE_PASSWORD', '2504')
totp_token = os.getenv('TOTP_SECRET', 'VKEN7FGDBEOFPJDNUYMU5GQ3DY')

def generate_totp(secret):
    return TOTP(secret).now()

def login_and_get_token():
    try:
        smartApi = SmartConnect(api_key)
        totp = generate_totp(totp_token)
        data = smartApi.generateSession(username, pwd, totp)

        if not data['status']:
            raise Exception(f"Login failed: {data.get('message', 'Unknown error')}")

        logger.info("Login successful")
        return data['data']['jwtToken']
    except Exception as e:
        logger.error(f"Login error: {str(e)}")
        raise Exception("Authentication failed")

def fetch_historical_data(symboltoken, fromdate, todate):
    try:
        authToken = login_and_get_token()
        
        conn = http.client.HTTPSConnection("apiconnect.angelone.in")
        payload = json.dumps({
            "exchange": "NSE",
            "symboltoken": symboltoken,
            "interval": "FIFTEEN_MINUTE",
            "fromdate": fromdate,
            "todate": todate
        })
        
        headers = {
            'Authorization': authToken,  # Removed 'Bearer' if API doesn't expect it
            'X-PrivateKey': api_key,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-SourceID': 'WEB'
        }
        
        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)
        res = conn.getresponse()
        
        if res.status != 200:
            error = res.read().decode()
            raise Exception(f"API Error {res.status}: {error}")
            
        data = json.loads(res.read().decode())
        return data
        
    except Exception as e:
        logger.error(f"API Error: {str(e)}")
        return None