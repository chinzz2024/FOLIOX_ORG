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
        
        # Format dates properly - Angel One might expect a specific format
        # Try ISO format with T separator instead of space
        def format_date(dt_str):
            try:
                dt = datetime.strptime(dt_str, "%Y-%m-%d %H:%M")
                return dt.strftime("%Y-%m-%dT%H:%M:00")  # ISO format with seconds
            except ValueError:
                raise ValueError(f"Invalid date format: {dt_str}. Use 'YYYY-MM-DD HH:MM'")
        
        formatted_from = format_date(fromdate)
        formatted_to = format_date(todate)
        
        # Create connection with timeout
        conn = http.client.HTTPSConnection("apiconnect.angelone.in", timeout=15)
        
        # Update payload with properly formatted data
        payload = json.dumps({
            "exchange": "NSE",
            "symboltoken": symboltoken,
            "interval": "ONE_MINUTE",
            "fromdate": formatted_from,
            "todate": formatted_to
        })
        
        # Make sure Authorization header is correctly formatted
        headers = {
            'Authorization': authToken,  # No space before token
            'X-PrivateKey': api_key,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-SourceID': 'WEB',  # Include all required headers
            'X-UserType': 'USER'
        }
        
        print(f"Request payload: {payload}")
        print(f"Request headers: {headers}")
        
        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)
        res = conn.getresponse()
        response_data = res.read().decode('utf-8')
        
        print(f"Response status: {res.status}")
        print(f"Response data: {response_data}")
        
        if res.status != 200:
            print(f"API Error {res.status}: {response_data}")
            raise Exception(f"API returned {res.status}: {response_data}")
            
        data = json.loads(response_data)
        return data
            
    except Exception as e:
        print(f"Error in fetch_historical_data: {str(e)}")
        raise
    finally:
        if conn:
            conn.close()