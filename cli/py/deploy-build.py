import core
import creds

url = core.apiurl('build')
username, password = creds.get(core.host(url))

print('starting build...')

core.request(url, username, password)
