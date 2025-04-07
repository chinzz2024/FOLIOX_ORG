import http.client
import json
import logging
import os
from SmartApi import SmartConnect
from pyotp import TOTP

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
        authToken = login_and_get_token()
        if not authToken:
            raise Exception("Failed to obtain authentication token")

        conn = http.client.HTTPSConnection("apiconnect.angelone.in", timeout=10)
        
        payload = json.dumps({
            "exchange": "NSE",
            "symboltoken": symboltoken,
            "interval": "ONE_DAY",  # Changed from FIFTEEN_MINUTE for testing
            "fromdate": fromdate,
            "todate": todate
        })
        
        headers = {
            'Authorization': authToken,
            'X-PrivateKey': api_key,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-SourceID': 'WEB',
            'X-UserType': 'USER'
        }
        
        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)
        
        res = conn.getresponse()
        response_data = res.read().decode()
        
        if res.status != 200:
            logger.error(f"API returned {res.status}: {response_data}")
            raise Exception(f"API Error {res.status}: {response_data}")
            
        data = json.loads(response_data)
        
        # Validate response structure
        if not data.get('data'):
            logger.error(f"Unexpected response format: {data}")
            raise Exception("Invalid data format received from API")
            
        return data
        
    except http.client.HTTPException as e:
        logger.error(f"HTTP Exception: {str(e)}")
        raise Exception("Network error occurred")
    except json.JSONDecodeError:
        logger.error("Failed to decode API response")
        raise Exception("Invalid API response")
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise
    finally:
        conn.close()  # Ensure connection is always closed