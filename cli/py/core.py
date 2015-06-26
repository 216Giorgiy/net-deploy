import os
import json
import requests
import urllib

# find the root directory containing deploy.json
def root():
	dir = os.getcwd()
	while True:
		if os.path.isfile(os.path.join(dir, "deploy.json")):
			return dir
		if dir == '/':
			break
		dir = os.path.dirname(dir)

	return None

def configpath():
	r = root()
	if not r:
		return None
	return os.path.join(r, "deploy.json")

def config():
	path = configpath()
	if not path:
		return None

	with open(path, 'r') as f:
		return json.load(f)

def app():
	return config()['app']

def baseurl():
	return config()['url']

def apiurl(action, url=None, appName=None):
	if not url:
		url = baseurl()
	if not appName:
		appName = app()

	return "{}/api/{}/{}".format(url, appName, action)

# http functions
def host(url):
	return urllib.parse.urlparse(url).netloc

def request(url, username, password):
	auth = requests.auth.HTTPBasicAuth(username, password)
	r = requests.get(url, stream=True, auth=auth)
	if r.status_code == 401:
		print("error: invalid credentials")
		return

	for chunk in r.iter_content(1):
		print(chunk.decode('utf-8'), end="")
