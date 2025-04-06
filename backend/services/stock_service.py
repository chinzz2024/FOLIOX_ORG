import aiohttp
import asyncio
from bs4 import BeautifulSoup
from flask_caching import Cache
from datetime import datetime, timedelta

cache = Cache(config={'CACHE_TYPE': 'SimpleCache'})

async def fetch_page(session, url):
    try:
        async with session.get(url, timeout=10) as response:
            return await response.text()
    except:
        return None

async def process_article(article, existing_titles):
    title_tag = article.find('h2')
    if not title_tag:
        return None
    
    title = title_tag.get_text(strip=True)
    if title in existing_titles:
        return None
        
    link = title_tag.find('a')['href'] if title_tag.find('a') else None
    if not link:
        return None
        
    source_tag = article.find('span', class_='author')
    source = source_tag.get_text(strip=True) if source_tag else "MoneyControl"
    
    return {
        'title': title,
        'link': link,
        'source': source
    }

async def fetch_fresh_news():
    base_url = "https://www.moneycontrol.com/news/business/stocks/"
    existing_titles = set()
    news_items = []
    
    async with aiohttp.ClientSession() as session:
        # Process first 3 pages (optimized from original 9)
        for page_num in range(1, 4):
            url = base_url if page_num == 1 else f"{base_url}page-{page_num}/"
            html = await fetch_page(session, url)
            if not html:
                continue
                
            soup = BeautifulSoup(html, 'html.parser')
            articles = soup.find_all('li', class_='clearfix')
            
            for article in articles:
                news_item = await process_article(article, existing_titles)
                if news_item:
                    news_items.append(news_item)
                    existing_titles.add(news_item['title'])
                    
                    # Early exit if we have enough items
                    if len(news_items) >= 100:
                        return news_items
    
    return news_items

def get_cached_news():
    # Check cache first
    cached_news = cache.get('stock_news')
    if cached_news:
        return cached_news
    
    # Fetch fresh news if cache is empty
    fresh_news = asyncio.run(fetch_fresh_news())
    
    # Cache for 30 minutes
    cache.set('stock_news', fresh_news, timeout=1800)
    return fresh_news