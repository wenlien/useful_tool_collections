import logging
import os
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
import sys
import time
from webdriver_manager.chrome import ChromeDriverManager

# Initialize Logger
# FORMAT = '%(asctime)s %(clientip)-15s %(user)-8s %(message)s'
FORMAT = '[%(levelname)s] - %(asctime)s - %(message)s'
# logging.basicConfig(format=FORMAT)
logging.basicConfig(format=FORMAT, filename='/tmp/gilmore.log', level=logging.INFO)
# logging.basicConfig(format=FORMAT, level=logging.INFO)
# logging.basicConfig(format=FORMAT, level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Initialize Chrome WebDriver
service = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=service)

# URL for the login page
# login_url = 'https://www.google.com'
# login_url = 'https://aws.gilmoreglobal.com/en/login'
# logger.info(len(sys.argv))
# logger.debug(len(sys.argv))
if len(sys.argv) < 2:
    logger.error(f'Login URL is required ({len(sys.argv)}), exit!')
    exit(1)
else:
    login_url = sys.argv[1]
    logger.debug(f'Login URL: {login_url}')

# Your login credentials
username = os.getenv('username')
password = os.getenv('password')
logger.debug(f'username: {username}, password: {password}')

# Load the login page
driver.get(login_url)

# Find the username and password input fields and enter the credentials
username_input = driver.find_element(by='name', value='username')
password_input = driver.find_element(by='name', value='password')

username_input.send_keys(username)
password_input.send_keys(password)

# Submit the login form
password_input.send_keys(Keys.ENTER)

# Add a delay to allow time for any redirects or dynamic content loading
time.sleep(1)

# Check if login was successful
if 'Welcome' in driver.page_source:
    logger.info('Login successful!')
    # Now you can proceed with further actions after successful login
else:
    logger.error('Login failed!')

# Close the browser window
driver.quit()

