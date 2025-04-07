import aiohttp
import asyncio
from bs4 import BeautifulSoup
from datetime import datetime
from extensions import cache
from config import Config

class NewsScraper:
    def __init__(self):
        self.session = None
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        }

    async def _login(self):
        try:
            self.session = aiohttp.ClientSession(headers=self.headers)
            login_data = {
                'email': Config.MC_EMAIL,
                'pwd': Config.MC_PASSWORD,
                'remember': 'on',
                'redirect': 'https://www.moneycontrol.com/'
            }
            
            async with self.session.post(
                Config.MC_LOGIN_URL,
                data=login_data,
                allow_redirects=True,
                timeout=aiohttp.ClientTimeout(total=10)
            ) as response:
                if response.status == 200:
                    # Verify login by checking protected page
                    test_url = "https://www.moneycontrol.com/portfolio-management/"
                    async with self.session.get(test_url, allow_redirects=False) as test_res:
                        return test_res.status == 200
        except Exception as e:
            print(f"Login error: {str(e)}")
            return False

    async def get_news(self):
        # Check cache first
        if cached := cache.get('cached_news'):
            return cached

        if not await self._login():
            raise Exception("MoneyControl login failed")

        try:
            async with self.session.get(
                Config.MC_BASE_URL,
                timeout=aiohttp.ClientTimeout(15)
            ) as response:
                if response.status == 200:
                    html = await response.text()
                    news = self._parse_news(html)
                    cache.set('cached_news', news, timeout=1800)
                    return news
                raise Exception(f"HTTP Error: {response.status}")
        finally:
            await self.session.close()

    def _parse_news(self, html):
        soup = BeautifulSoup(html, 'html.parser')
        articles = soup.find_all('li', class_='clearfix')[:15]
        news_items = []
        
        for article in articles:
            title_tag = article.find('h2')
            if not title_tag:
                continue
                
            source_tag = article.find('span', class_='author')
            news_items.append({
                'title': title_tag.get_text(strip=True),
                'link': title_tag.find('a')['href'] if title_tag.find('a') else '#',
                'source': source_tag.get_text(strip=True) if source_tag else "MoneyControl",
                'time': datetime.now().isoformat()
            })
        
        return news_items