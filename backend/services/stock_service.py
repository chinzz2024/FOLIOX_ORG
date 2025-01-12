import requests
from bs4 import BeautifulSoup

def fetch_stock_news():
    session = requests.Session()

    # Define the login URL and the page to scrape after login
    login_url = "https://m.moneycontrol.com/login.php?cpurl=https://www.moneycontrol.com/"
    scrape_url = "https://www.moneycontrol.com/news/business/stocks/"

    # Set your login credentials
    login_payload = {
        'user_id': 'joleoran@gmail.com',  # Replace with your actual email ID
        'password': 'iXQDIX@pZ4'  # Replace with your actual password
    }

    # Send a POST request to the login page
    login_response = session.post(login_url, data=login_payload)

    if login_response.status_code == 200:
        # Send a GET request to scrape the protected page
        scrape_response = session.get(scrape_url)

        if scrape_response.status_code == 200:
            soup = BeautifulSoup(scrape_response.text, 'html.parser')
            articles = soup.find_all('li', class_='clearfix')

            stock_news = []

            for article in articles:
                title_tag = article.find('h2')
                if title_tag:
                    title = title_tag.get_text(strip=True)
                    link = title_tag.find('a')['href']
                    stock_news.append({'title': title, 'link': link})

            return stock_news
        else:
            return {'error': 'Failed to retrieve the page'}
    else:
        return {'error': 'Login failed'}
