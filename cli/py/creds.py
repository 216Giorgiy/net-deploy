import getpass
import os

def get(target):
    username = os.environ.get("DEPLOY_USERNAME", None)
    password = os.environ.get("DEPLOY_PASSWORD", None)

    if not username or not password:
        try:
            username = input("deploy username: ")
            password = getpass.getpass("password: ")
        except KeyboardInterrupt:
            print()
            exit(1)

        os.environ["DEPLOY_USERNAME"] = username
        os.environ["DEPLOY_PASSWORD"] = password

    return username, password
