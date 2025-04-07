import aiohttp
import asyncio
from bs4 import BeautifulSoup
import json
from datetime import datetime
from extensions import cache  # Import from extensions instead of app
class NewsScraper:
    def __init__(self):
        self.login_url = "https://www.moneycontrol.com/mc/login"
        self.base_url = "https://www.moneycontrol.com/news/business/stocks/"
        self.session = None
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
        }

    async def _login(self):
        self.session = aiohttp.ClientSession(headers=self.headers)
        login_data = {
            'email': 'joleoran@gmail.com',
            'pwd': 'iXQDIX@pZ4',
            'remember': 'on',
            'redirect': 'https://www.moneycontrol.com/'
        }
        
        try:
            async with self.session.post(
                self.login_url,
                data=login_data,
                allow_redirects=True,
                timeout=aiohttp.ClientTimeout(total=10)
            ) as response:
                if response.status == 200:
                    # Check if login was successful by accessing a protected page
                    test_response = await self.session.get(
                        'https://www.moneycontrol.com/portfolio-management/',
                        allow_redirects=False
                    )
                    if test_response.status == 200:
                        return True
        except Exception as e:
            print(f"Login error: {str(e)}")
        return False

    async def _scrape_page(self, url):
        try:
            async with self.session.get(
                url,
                timeout=aiohttp.ClientTimeout(total=15),
                headers=self.headers
            ) as response:
                if response.status == 200:
                    return await response.text()
                print(f"Failed to fetch page: {response.status}")
        except Exception as e:
            print(f"Scraping error: {str(e)}")
        return None

    async def get_news(self):
        cached = cache.get('cached_news')
        if cached:
            print("Returning cached news")
            return cached

        if not await self._login():
            print("Login failed")
            return []

        news_items = []
        
        # Only scrape first page to be faster
        url = self.base_url
        print(f"Scraping: {url}")
        html = await self._scrape_page(url)
        if not html:
            await self.session.close()
            return []
                
        soup = BeautifulSoup(html, 'html.parser')
        articles = soup.find_all('li', class_='clearfix')[:15]  # Limit to 15 articles
        
        for article in articles:
            title_tag = article.find('h2')
            if not title_tag:
                continue
                
            title = title_tag.get_text(strip=True)
            link = title_tag.find('a')['href'] if title_tag.find('a') else None
            source_tag = article.find('span', class_='author')
            source = source_tag.get_text(strip=True) if source_tag else "MoneyControl"
            
            if link and not any(n['title'] == title for n in news_items):
                news_items.append({
                    'title': title,
                    'link': link,
                    'source': source,
                    'time': datetime.now().isoformat()
                })

        await self.session.close()
        
        if news_items:
            cache.set('cached_news', news_items)
            print(f"Scraped {len(news_items)} news items")
        
        return news_items