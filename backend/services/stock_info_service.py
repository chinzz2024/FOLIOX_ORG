import pyotp
from logzero import logger
from SmartApi import SmartConnect

# Your Angel One API credentials
api_key = 'VJ5iztNm'
username = 'AAAF841327'
pwd = '2504'
token = "VKEN7FGDBEOFPJDNUYMU5GQ3DY"

def get_stock_info_by_symbol(symbol):
    try:
        # Initialize SmartConnect API
        smartApi = SmartConnect(api_key)
        
        # Generate OTP based on the token
        totp = pyotp.TOTP(token).now()
        
        # Generate session
        data = smartApi.generateSession(username, pwd, totp)
        
        if data['status'] == False:
            logger.error(data)
            raise Exception('Failed to generate session')

        auth_token = data['data']['jwtToken']
        refresh_token = data['data']['refreshToken']
        
        # Fetch stock data based on the symbol
        historic_param = {
            "exchange": "NSE",
            "symboltoken": symbol,  # Use the symbol dynamically
            "interval": "ONE_MINUTE",
            "fromdate": "2021-02-08 09:00", 
            "todate": "2021-02-08 09:16"
        }
        
        # Get historical candle data
        candle_data = smartApi.getCandleData(historic_param)

        # Extract necessary stock data
        stock_info = []
        for item in candle_data['data']:
            stock_info.append({
                'price': item['close'],
                'date': item['datetime']
            })
        
        return stock_info
    except Exception as e:
        logger.exception(f"Error fetching stock info: {e}")
        raise
