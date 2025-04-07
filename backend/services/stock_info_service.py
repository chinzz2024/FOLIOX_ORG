import http.client
import json
import logging
import os
from SmartApi import SmartConnect
from pyotp import TOTP
from datetime import datetime
logger = logging.getLogger(__name__)

api_key = "VJ5iztNm"
username = "AAAF841327"
pwd = "2504"
totp_token = "VKEN7FGDBEOFPJDNUYMU5GQ3DY"

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
        # Validate inputs first
        if not isinstance(symboltoken, str) or not symboltoken.isdigit():
            raise ValueError("Symbol token must be a numeric string")
            
        # Convert dates to Angel One's expected format
        def format_date(dt_str):
            try:
                dt = datetime.strptime(dt_str, "%Y-%m-%d %H:%M")
                return dt.strftime("%Y-%m-%d %H:%M")
            except ValueError:
                raise ValueError(f"Invalid date format: {dt_str}. Use 'YYYY-MM-DD HH:MM'")

        formatted_from = format_date(fromdate)
        formatted_to = format_date(todate)

        authToken = login_and_get_token()
        conn = http.client.HTTPSConnection("apiconnect.angelone.in", timeout=10)
        
        payload = json.dumps({
            "exchange": "NSE",
            "symboltoken": symboltoken,
            "interval": "ONE_MINUTE",  # Try different intervals if needed
            "fromdate": formatted_from,
            "todate": formatted_to
        })
        
        headers = {
            'Authorization': authToken,
            'X-PrivateKey': api_key,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }

        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)
        res = conn.getresponse()
        response_data = res.read().decode('utf-8')

        if res.status != 200:
            logger.error(f"API Error {res.status}: {response_data}")
            raise Exception(f"API returned {res.status}")

        try:
            data = json.loads(response_data)
            if not data.get('data'):
                logger.error(f"Empty data in response: {data}")
                raise Exception("No data found in response")
                
            # Validate candle data format
            candles = data['data'].get('data', [])
            if candles and len(candles[0]) != 6:
                raise ValueError("Unexpected candle data format")
                
            return data
            
        except json.JSONDecodeError:
            logger.error(f"Invalid JSON: {response_data}")
            raise Exception("Invalid API response format")
            
    except Exception as e:
        logger.error(f"Error in fetch_historical_data: {str(e)}", exc_info=True)
        raise
    finally:
        if 'conn' in locals():
            conn.close()