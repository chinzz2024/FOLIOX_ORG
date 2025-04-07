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
    conn = None
    try:
        # Get a fresh token for each request
        authToken = login_and_get_token()
        
        # Angel One requires specific date format: "YYYY-MM-DD HH:MM"
        def format_date(dt_str):
            try:
                # First try parsing with time component
                dt = datetime.strptime(dt_str, "%Y-%m-%d %H:%M")
                return dt.strftime("%Y-%m-%d %H:%M")
            except ValueError:
                try:
                    # Fallback to date-only format (will use default time)
                    dt = datetime.strptime(dt_str, "%Y-%m-%d")
                    return dt.strftime("%Y-%m-%d 09:15")  # Default to market open time
                except ValueError:
                    raise ValueError(f"Invalid date format: {dt_str}. Use 'YYYY-MM-DD' or 'YYYY-MM-DD HH:MM'")
        
        formatted_from = format_date(fromdate)
        formatted_to = format_date(todate)
        
        # Create connection with timeout
        conn = http.client.HTTPSConnection("apiconnect.angelone.in", timeout=15)
        
        # Update payload with properly formatted data
        payload = json.dumps({
            "exchange": "NSE",
            "symboltoken": symboltoken,
            "interval": "FIFTEEN_MINUTE",
            "fromdate": formatted_from,
            "todate": formatted_to
        })
        
        # Headers with proper authorization
        headers = {
            'Authorization': authToken,
            'X-PrivateKey': api_key,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-SourceID': 'WEB',
            'X-UserType': 'USER',
            'X-ClientLocalIP': '127.0.0.1',
            'X-ClientPublicIP': '106.193.147.98',
            'X-MACAddress': '74:12:b3:c5:f6:76'
        }
        
        logger.info(f"Request payload: {payload}")
        logger.info(f"Request headers: {json.dumps(headers, indent=2)}")
        
        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)
        res = conn.getresponse()
        response_data = res.read().decode('utf-8')
        
        logger.info(f"Response status: {res.status}")
        logger.info(f"Response data: {response_data}")
        
        if res.status != 200:
            error_msg = f"API Error {res.status}: {response_data}"
            logger.error(error_msg)
            raise Exception(error_msg)
            
        data = json.loads(response_data)
        
        if not data.get('status', False):
            raise Exception(data.get('message', 'Unknown API error'))
            
        return data
            
    except Exception as e:
        logger.error(f"Error in fetch_historical_data: {str(e)}")
        raise
    finally:
        if conn:
            conn.close()