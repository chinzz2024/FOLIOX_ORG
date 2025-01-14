import http.client
import pyotp
import json
from logzero import logger
from SmartApi import SmartConnect

api_key = 'VJ5iztNm'
username = 'AAAF841327'
pwd = '2504'

# Function to generate TOTP
def generate_totp(token):
    """Generates a Time-based One-Time Password (TOTP) from the provided token."""
    totp = pyotp.TOTP(token).now()
    logger.info(f"Generated TOTP: {totp}")
    return totp

def login(totp_token):
    """Logs in to the Smart API using username, password, and TOTP."""
    try:
        totp = generate_totp(totp_token)
        smartApi = SmartConnect(api_key)

        # Generate session using username, password, and TOTP
        data = smartApi.generateSession(username, pwd, totp)

        if data['status'] == False:
            raise Exception(f"Login failed: {data}")
        
        authToken = data['data']['jwtToken']
        refreshToken = data['data']['refreshToken']

        logger.info("Login successful.")
        return authToken, refreshToken

    except Exception as e:
        logger.error(f"Login failed: {e}")
        raise e

def fetch_historical_data(authToken, symboltoken, fromdate, todate):
    """Fetches historical data for a given symbol token from the API."""
    try:
        # Set the parameters for the API request
        historicParam = {
            "exchange": "NSE",
            "symboltoken": symboltoken,
            "interval": "ONE_MINUTE",
            "fromdate": fromdate,  # example: "2021-02-08 09:00"
            "todate": todate,      # example: "2021-02-08 09:16"
        }

        # Log the parameters being sent to the API
        logger.info(f"Historic API request parameters: {historicParam}")

        # Make the API call using http.client with the authToken
        conn = http.client.HTTPSConnection("apiconnect.angelone.in")
        payload = json.dumps(historicParam)

        # Set the headers for the request
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

        # Log the headers for debugging
        logger.info(f"Request Headers: {headers}")

        # Send the API request
        conn.request("POST", "/rest/secure/angelbroking/historical/v1/getCandleData", payload, headers)

        res = conn.getresponse()
        data = res.read()

        # Log the response for debugging
        if data:
            logger.info(f"API response: {data.decode('utf-8')}")
        else:
            logger.warning("Empty response received from API.")

        return data.decode("utf-8")

    except Exception as e:
        logger.exception(f"Historic API failed: {e}")
        return None

# Example usage
if __name__ == "__main__":
    totp_token = 'VKEN7FGDBEOFPJDNUYMU5GQ3DY'  # Replace with your actual TOTP secret
    try:
        # Log in and get the auth token
        authToken, refreshToken = login(totp_token)

        # Fetch historical data
        symboltoken = "3045"  # Example symbol token
        fromdate = "2021-02-08 09:00"
        todate = "2021-02-08 09:16"
        data = fetch_historical_data(authToken, symboltoken, fromdate, todate)

        if data:
            logger.info(f"Historical Data: {data}")
        else:
            logger.warning("Failed to fetch historical data.")
    
    except Exception as e:
        logger.error(f"Error: {e}")
