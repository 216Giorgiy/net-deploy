import os
import base64
from pbkdf2 import pbkdf2
import codecs
import hashlib
import sys
import getpass

if len(sys.argv) < 2:
	print("error: username is required")
	exit(1)

username = sys.argv[1]
password = getpass.getpass('password for %s:' % username).encode('utf-8')
confirm = getpass.getpass('re-enter password:').encode('utf-8')

if confirm != password:
	print("error: passwords didn't match")
	exit(1)

ITERATIONS = 1000
SALT_BYTESIZE = 24
HASH_BYTESIZE = 24

salt = os.urandom(SALT_BYTESIZE)
b64salt = base64.b64encode(salt).decode('utf-8')

hash = pbkdf2(hashlib.sha1, password, salt, ITERATIONS, HASH_BYTESIZE)
b64hash = base64.b64encode(hash).decode('utf-8')

print("{} {}:{}:{}".format(username, ITERATIONS, b64salt, b64hash))