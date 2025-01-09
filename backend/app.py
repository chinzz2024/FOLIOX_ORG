from flask import Flask, jsonify
from flask_cors import CORS  
import requests
from bs4 import BeautifulSoup

app = Flask(__name__)
CORS(app) 
@app.route('/scrape_news', methods=['GET'])
def scrape_news():
    # Define the URL of the RSS feed
    rss_url = 'https://www.moneycontrol.com/rss/MCtopnews.xml'

    try:
        # Fetch the RSS feed
        response = requests.get(rss_url)
        response.raise_for_status()  # Check if the request was successful
        
        # Parse the XML content
        soup = BeautifulSoup(response.content, 'xml')
        items = soup.find_all('item')

        # Extract titles and links from the RSS feed
        news_articles = []
        for item in items:
            title = item.find('title').text
            link = item.find('link').text
            news_articles.append({'title': title, 'link': link})

        # Return the news articles as a JSON response
        return jsonify(news_articles)
    
    except requests.exceptions.RequestException as e:
        return jsonify({'error': f'Failed to fetch news: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)


