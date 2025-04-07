import aiohttp
import asyncio
from bs4 import BeautifulSoup
from datetime import datetime
from extensions import cache
from config import Config
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, 
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('news_scraper')

class NewsScraper:
    def __init__(self, min_news_items=50):
        self.session = None
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        }
        self.base_url = "https://www.moneycontrol.com/news/business/stocks/page-{}/"  # Updated to include page placeholder
        self.start_page = 2  # Start from page 2
        self.end_page = 9    # Go up to page 9
        self.min_news_items = min_news_items

    async def _create_session(self):
        """Create an aiohttp session if one doesn't exist"""
        if not self.session:
            self.session = aiohttp.ClientSession(headers=self.headers)
        return self.session

    async def fetch_page(self, page_num):
        """Fetch and parse a single page of news"""
        await self._create_session()
        
        url = self.base_url.format(page_num)
        logger.info(f"Fetching page {page_num}: {url}")
        
        try:
            async with self.session.get(
                url, 
                timeout=aiohttp.ClientTimeout(total=30)
            ) as response:
                if response.status != 200:
                    logger.error(f"Failed to fetch page {page_num}, status: {response.status}")
                    return []
                
                html = await response.text()
                news_items = self._parse_news(html)
                logger.info(f"Found {len(news_items)} news items on page {page_num}")
                
                # Add page number metadata to each item
                for item in news_items:
                    item['page'] = page_num
                    
                return news_items
                
        except Exception as e:
            logger.error(f"Error fetching page {page_num}: {str(e)}")
            return []

    async def get_news(self):
        """Get news from pages 2-9"""
        cache_key = f'mc_stock_news_pages_2_to_9'
        
        # Check cache first
        cached_news = cache.get(cache_key)
        if cached_news and len(cached_news) >= self.min_news_items:
            logger.info(f"Returning {len(cached_news)} cached news items")
            return cached_news
        
        try:
            await self._create_session()
            
            # Create tasks for each page (2-9)
            tasks = [self.fetch_page(page) for page in range(self.start_page, self.end_page + 1)]
            
            # Execute all page fetch tasks concurrently
            results = await asyncio.gather(*tasks)
            
            # Combine all news items
            all_news = []
            for page_items in results:
                if page_items:
                    all_news.extend(page_items)
            
            # Remove duplicates based on title
            unique_news = []
            seen_titles = set()
            
            for item in all_news:
                if item['title'] not in seen_titles:
                    unique_news.append(item)
                    seen_titles.add(item['title'])
            
            total_items = len(unique_news)
            logger.info(f"Successfully retrieved {total_items} unique news items from pages {self.start_page}-{self.end_page}")
            
            # Sort by page number and then by position on page
            unique_news.sort(key=lambda x: (x['page'], x.get('position', 0)))
            
            # Cache the results if we found any
            if unique_news:
                cache.set(cache_key, unique_news, timeout=1800)  # Cache for 30 minutes
            
            return unique_news
            
        except Exception as e:
            logger.error(f"Error in get_news: {str(e)}")
            import traceback
            traceback.print_exc()
            return []
        finally:
            # Close the session when done
            if self.session:
                await self.session.close()
                self.session = None

    def _parse_news(self, html):
        """Parse HTML content to extract news items"""
        soup = BeautifulSoup(html, 'html.parser')
        news_items = []
        
        # Main selector for MoneyControl's stock news pages
        articles = soup.find_all('li', class_='clearfix')
        
        for idx, article in enumerate(articles):
            item = self._extract_article_data(article)
            if item:
                item['position'] = idx  # Track position on page
                news_items.append(item)
        
        return news_items

    def _extract_article_data(self, element):
        """Extract data from an article element"""
        try:
            title_tag = element.find('h2')
            if not title_tag:
                title_tag = element.find('h3')
                if not title_tag:
                    return None
            
            link_tag = title_tag.find('a')
            if not link_tag:
                return None
            
            title = link_tag.get_text(strip=True)
            link = link_tag.get('href', '')
            
            if not title or not link:
                return None
            
            # Extract timestamp
            timestamp_tag = element.find('span', class_='meta-date')
            if not timestamp_tag:
                timestamp_tag = element.find('span', class_='date')
            
            timestamp = timestamp_tag.get_text(strip=True) if timestamp_tag else ""
            
            # Extract source/author
            source_tag = element.find('span', class_='author')
            source = source_tag.get_text(strip=True) if source_tag else "MoneyControl"
            
            # Extract summary
            summary_tag = element.find('p')
            summary = summary_tag.get_text(strip=True) if summary_tag else ""
            
            # Get image URL
            img_tag = element.find('img')
            image_url = img_tag.get('data-src', '') if img_tag else ""
            if not image_url and img_tag:
                image_url = img_tag.get('src', '')
            
            return {
                'title': title,
                'link': link,
                'timestamp': timestamp,
                'source': source,
                'summary': summary,
                'image_url': image_url,
                'scraped_at': datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error extracting article data: {str(e)}")
            return None

async def main():
    scraper = NewsScraper(min_news_items=50)
    try:
        news = await scraper.get_news()
        print(f"\nSuccessfully retrieved {len(news)} news items from pages 2-9")
        
        # Print summary by page
        page_counts = {}
        for item in news:
            page = item.get('page', 'unknown')
            page_counts[page] = page_counts.get(page, 0) + 1
            
        print("\nNews items per page:")
        for page in sorted(page_counts.keys()):
            print(f"  Page {page}: {page_counts[page]} items")
        
        # Print first few items from different pages
        if news:
            print("\nSample news items:")
            samples_shown = 0
            current_page = None
            
            for item in news:
                if samples_shown >= 10:
                    break
                    
                page = item.get('page', 'unknown')
                if page != current_page:
                    print(f"\n=== Page {page} ===")
                    current_page = page
                    samples_shown = 0
                
                if samples_shown < 3:  # Show 3 items per page
                    print(f"\nTitle: {item['title']}")
                    print(f"Link: {item['link']}")
                    print(f"Time: {item.get('timestamp', 'N/A')}")
                    samples_shown += 1
    
    except Exception as e:
        print(f"Error running main scraper: {e}")

if __name__ == "__main__":
    asyncio.run(main())