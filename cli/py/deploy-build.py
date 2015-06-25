import core
import getpass

url = core.apiurl('build')

username = input('username: ')
password = getpass.getpass('password: ')

print('starting build...')

core.request(url, username, password)

