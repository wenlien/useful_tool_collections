import os
import random
import requests
import time
from bs4 import BeautifulSoup

# URL for the login page
login_url = 'https://aws.gilmoreglobal.com/en/login'

# Greeting
greeting = 'Welcome to the Gilmore Global AWS Training & Certification Bookstore'

# Your login credentials
username = os.getenv('username')
password = os.getenv('password')

# List of User-Agent strings to randomize from
user_agents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0',
    # Add more User-Agent strings as needed
]

# Create a session to persist cookies across requests
session = requests.Session()

# Fetch the login page to obtain the CSRF token
login_page = session.get(login_url)
soup = BeautifulSoup(login_page.text, 'html.parser')
csrf_token = login_page.headers.get('csrf-token')

# Prepare the login data including the CSRF token
login_data = {
    'username': username,
    'password': password,
    '_token': csrf_token
}

# Perform the login request
print(login_data)

# Additional headers to mimic a browser
headers = {
    'User-Agent': random.choice(user_agents),
    'Referer': login_url,
}

# Merge headers with session headers
session.headers.update(headers)

# Post request
response = session.post(login_url, data=login_data)

# Check if login was successful
print(response.text)
if greeting in response.text:
    print('Login successful!')
    # Now you can make subsequent requests using the session object
    # For example:
    # response = session.get('https://gilmore_website.com/protected_page')
else:
    print('Login failed!')

