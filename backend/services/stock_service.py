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
            
            # First, get the login page to extract any CSRF tokens if needed
            async with self.session.get(Config.MC_LOGIN_URL) as pre_response:
                pre_html = await pre_response.text()
                soup = BeautifulSoup(pre_html, 'html.parser')
                
                # Look for possible CSRF token (adjust selector based on actual page structure)
                csrf_token = soup.select_one('input[name="csrf_token"]')
                csrf_value = csrf_token['value'] if csrf_token else None
            
            # Prepare login data with CSRF token if found
            login_data = {
                'email': Config.MC_EMAIL,
                'pwd': Config.MC_PASSWORD,
                'remember': 'on',
                'redirect': 'https://www.moneycontrol.com/'
            }
            
            if csrf_value:
                login_data['csrf_token'] = csrf_value
            
            # Perform login
            async with self.session.post(
                Config.MC_LOGIN_URL,
                data=login_data,
                allow_redirects=True,
                timeout=aiohttp.ClientTimeout(total=15)
            ) as response:
                # Store cookies from the response
                cookies = response.cookies
                
                # Check if login was successful by looking for authentication indicators
                # This could be checking for specific cookies or content in the response
                html = await response.text()
                
                # Better login verification - look for elements that appear only when logged in
                # (like username display or logout button)
                soup = BeautifulSoup(html, 'html.parser')
                
                # Check for login indicators (adjust selectors based on actual page)
                username_element = soup.select_one('.username-display, .user-name, .profile-name')
                logout_link = soup.select_one('a[href*="logout"], .logout-button')
                
                if username_element or logout_link:
                    print("Login successful - found user elements on page")
                    return True
                    
                # If we couldn't confirm login by HTML elements, try accessing a protected resource
                test_url = "https://www.moneycontrol.com/portfolio-management/"
                async with self.session.get(test_url) as test_res:
                    html = await test_res.text()
                    soup = BeautifulSoup(html, 'html.parser')
                    
                    # Look for elements that would only appear for logged-in users
                    portfolio_content = soup.select_one('.portfolio-content, .portfolio-summary')
                    
                    if portfolio_content:
                        print("Login confirmed via portfolio page access")
                        return True
                        
                    print("Login verification failed - couldn't access portfolio content")
                    return False
                    
        except Exception as e:
            print(f"Login error: {str(e)}")
            import traceback
            traceback.print_exc()
            return False

    async def get_news(self):
        # Check cache first
        if cached := cache.get('cached_news'):
            print("Returning cached news")
            return cached
        
        try:
            print("Attempting login to MoneyControl...")
            if not self.session:
                self.session = aiohttp.ClientSession(headers=self.headers)
                
            login_success = await self._login()
            if not login_success:
                print("Login failed, trying to access news without authentication")
                # Optionally try to access news without login as fallback
            else:
                print("Login successful, proceeding to fetch news")
                
            print(f"Requesting news from {Config.MC_BASE_URL}")
            async with self.session.get(
                Config.MC_BASE_URL,
                timeout=aiohttp.ClientTimeout(total=15)
            ) as response:
                print(f"Response status: {response.status}")
                if response.status == 200:
                    html = await response.text()
                    
                    # Save HTML for debugging if needed
                    with open("debug_response.html", "w", encoding="utf-8") as f:
                        f.write(html)
                        
                    print("Parsing news content...")
                    news = self._parse_news(html)
                    print(f"Found {len(news)} news items")
                    
                    if news:
                        cache.set('cached_news', news, timeout=1800)
                        return news
                    else:
                        print("No news items found in the HTML")
                        raise Exception("Failed to parse any news items")
                else:
                    raise Exception(f"HTTP Error: {response.status}")
        except Exception as e:
            print(f"News retrieval error: {str(e)}")
            import traceback
            traceback.print_exc()
            raise
        finally:
            if self.session:
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

# Add the public news scraping method as fallback
    async def get_public_news(self):
        """Fallback method to get news without requiring login"""
        try:
            if not self.session:
                self.session = aiohttp.ClientSession(headers=self.headers)
            
            # MoneyControl public news URLs that don't require login
            public_urls = [
                "https://www.moneycontrol.com/news/business/stocks/",
                "https://www.moneycontrol.com/news/business/markets/"
            ]
            
            all_news = []
            for url in public_urls:
                try:
                    async with self.session.get(
                        url,
                        timeout=aiohttp.ClientTimeout(total=15)
                    ) as response:
                        if response.status == 200:
                            html = await response.text()
                            news_items = self._parse_news(html)
                            all_news.extend(news_items)
                        else:
                            print(f"Failed to access {url}: {response.status}")
                except Exception as e:
                    print(f"Error accessing {url}: {str(e)}")
                    continue
            
            # Deduplicate news items based on title
            unique_news = []
            seen_titles = set()
            for item in all_news:
                if item['title'] not in seen_titles:
                    unique_news.append(item)
                    seen_titles.add(item['title'])
            
            if unique_news:
                cache.set('cached_news', unique_news, timeout=1800)
            
            return unique_news
        finally:
            if self.session:
                await self.session.close()