import os

class Config:
    MC_EMAIL = os.getenv('MC_EMAIL', 'joleoran@gmail.com')
    MC_PASSWORD = os.getenv('MC_PASSWORD', 'iXQDIX@pZ4')
    MC_LOGIN_URL = "https://m.moneycontrol.com/login.php?cpurl=https://www.moneycontrol.com/"
    MC_BASE_URL = "https://www.moneycontrol.com/news/business/stocks/"