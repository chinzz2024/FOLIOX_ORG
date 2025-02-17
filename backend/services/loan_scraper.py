import requests
from bs4 import BeautifulSoup

def scrape_loan_rates():
    url = "https://www.paisabazaar.com/home-loan/#rates"
    
    # Add headers to mimic a browser
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    }

    # Send the request with headers
    response = requests.get(url, headers=headers)

    # Check response status
    if response.status_code != 200:
        print(f"Failed to retrieve webpage. Status Code: {response.status_code}")
        return []

    # Parse the HTML
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Debug: Print the first 1000 characters of the HTML to inspect structure
    print(soup.prettify()[:1000])

    loan_rates = []

    # Updated scraping logic - Find loan rates table
    rows = soup.find_all("tr")  # Assuming loan rates are in table rows
    
    for row in rows:
        columns = row.find_all("td")
        
        if len(columns) >= 2:
            bank_name = columns[0].get_text(strip=True)
            rate = columns[1].get_text(strip=True)
            
            if bank_name and rate:
                loan_rates.append({"bank_name": bank_name, "rate": rate})

    loan_rates = loan_rates[6:]
    
    # Debug: Print the extracted loan rates for verification
    print("Extracted Loan Rates:", loan_rates)
    
    return loan_rates

if __name__ == "__main__":
    scrape_loan_rates()
