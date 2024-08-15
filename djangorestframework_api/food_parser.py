import requests
from bs4 import BeautifulSoup
import django
import os

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "drf_calorie_tracker.settings")
django.setup()

from tracker.models import FoodItem, UserProfile

OWNER_ID = 1

BASE_URL = "https://www.tablycjakalorijnosti.com.ua/tablytsya-yizhyi"
PAGE_PARAM = "?page="

def fetch_page(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response.content
    else:
        print(f"Failed to fetch {url}")
        return None

def parse_food_table(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    table = soup.find('table')
    food_items = []
    
    if table:
        rows = table.find_all('tr')
        for row in rows:
            columns = row.find_all('td')
            if len(columns) > 1:
                try:
                    food_item = {
                        'name': columns[0].text.strip(),
                        'calories': float(columns[1].text.strip()),
                        'protein': float(columns[2].text.strip()),
                        'fat': float(columns[3].text.strip()),
                        'carbohydrates': float(columns[4].text.strip()),
                    }
                    food_items.append(food_item)
                except ValueError as e:
                    continue
    return food_items

def save_food_items(food_items, owner):
    for item in food_items:
        food_item = FoodItem(
            owner=owner,
            name=item['name'],
            producer='tablycjakalorijnosti',  
            calories=item['calories'],
            protein=item['protein'],
            fat=item['fat'],
            carbohydrates=item['carbohydrates'],
            portion_size=100,  
            quantity_unit=FoodItem.GRAMS
        )
        food_item.save()

def main():
    try:
        owner = UserProfile.objects.get(id=OWNER_ID)
    except UserProfile.DoesNotExist:
        print(f"User with ID {OWNER_ID} does not exist.")
        return
    
    page = 1
    while True:
        url = BASE_URL + PAGE_PARAM + str(page)
        html_content = fetch_page(url)
        if not html_content:
            break
        
        food_items = parse_food_table(html_content)
        if not food_items:
            break
        
        save_food_items(food_items, owner)
        page += 1


if __name__ == "__main__":
    main()
