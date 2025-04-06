import requests
from bs4 import BeautifulSoup

def fetch_stock_news():
    session = requests.Session()

    # Define the login URL and base URL for stock news pages
    login_url = "https://m.moneycontrol.com/login.php?cpurl=https://www.moneycontrol.com/"
    base_url = "https://www.moneycontrol.com/news/business/stocks/"
    
    # Set your login credentials
    login_payload = {
        'user_id': 'joleoran@gmail.com',  # Replace with your actual email ID
        'password': 'iXQDIX@pZ4'  # Replace with your actual password
    }

    # Send a POST request to the login page
    login_response = session.post(login_url, data=login_payload)

    if login_response.status_code != 200:
        return {'error': 'Login failed'}

    stock_news = []
    pages_to_scrape = 9  # Number of pages to scrape (page-1 to page-9)

    for page_num in range(1, pages_to_scrape + 1):
        if page_num == 1:
            scrape_url = base_url
        else:
            scrape_url = f"{base_url}page-{page_num}/"
        
        try:
            # Send a GET request to scrape the page
            scrape_response = session.get(scrape_url)
            
            if scrape_response.status_code == 200:
                soup = BeautifulSoup(scrape_response.text, 'html.parser')
                articles = soup.find_all('li', class_='clearfix')
                
                for article in articles:
                    title_tag = article.find('h2')
                    if title_tag:
                        title = title_tag.get_text(strip=True)
                        link = title_tag.find('a')['href']
                        
                        # Extract source from the article (if available)
                        source_tag = article.find('span', class_='author')
                        source = source_tag.get_text(strip=True) if source_tag else "MoneyControl"
                        
                        # Only add if not already in the list (to avoid duplicates)
                        if not any(news['title'] == title for news in stock_news):
                            stock_news.append({
                                'title': title, 
                                'link': link,
                                'source': source
                            })
            else:
                print(f"Failed to retrieve page {page_num}")
                
        except Exception as e:
            print(f"Error scraping page {page_num}: {str(e)}")
            continue

    return stock_news[:200]  # Return maximum 100 news items to avoid too much data