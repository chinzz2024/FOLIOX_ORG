from bs4 import BeautifulSoup
import requests

def scrape_cartrade(max_price):
    url = "https://www.cartrade.com/new-cars/"
    try:
        response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
        response.raise_for_status()
        soup = BeautifulSoup(response.content, "html.parser")
        cars = []
        car_listings = soup.find_all("p", class_={"car_name","car_price"})

        for listing in car_listings:
            try:
                name = listing.find("p", class_="car_names").get_text(strip=True)
                price_text = listing.find("p", class_="car_price").get_text(strip=True)
                link = listing.find("a", class_="link")["href"]

                price_value = extract_price(price_text)
                if price_value <= max_price:
                    cars.append({
                        "name": name,
                        "price": price_text,
                        "link": f"https://www.cartrade.com{link}"
                    })
            except AttributeError:
                continue  # Skip invalid listings

        return cars
    except requests.exceptions.RequestException as e:
        return {"error": str(e)}

def extract_price(price_str):
    try:
        price_str = price_str.replace("₹", "").replace(",", "").strip()
        if "Lakh" in price_str:
            return float(price_str.replace("Lakh", "")) * 100000
        elif "Crore" in price_str:
            return float(price_str.replace("Crore", "")) * 10000000
        return float(price_str)
    except ValueError:
        return float("inf")
