import os
import json
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))

class Config(object):
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-probably-guess'
    MAIL_SERVER = os.environ.get('MAIL_SERVER')
    MAIL_PORT = int(os.environ.get('MAIL_PORT') or 25)
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS') is not None
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    LANGUAGES = ['en','es']
    ADMINS = json.loads(os.environ.get('ADMINS'))
    CONTACT = os.environ.get('CONTACT')
    TEST_ACCOUNT = os.environ.get('TEST_ACCOUNT')
    TEST_PASSWORD = os.environ.get('TEST_PASSWORD')
    LDAP_ADMIN = os.environ.get('LDAP_ADMIN')
    LDAP_PW = os.environ.get('LDAP_PW')
    LDAP_DC = os.environ.get('LDAP_DC')
    LDAP_HOST = os.environ.get('LDAP_HOST')
    LDAP_ATTR = json.loads(os.environ.get('LDAP_ATTR'))
    LDAP_PORT = 389
    LDAP_USE_SSL = False
    LDAP_ADD_SERVER = True
    LDAP_BASE_DN = LDAP_DC
    LDAP_USER_DN = 'ou=people'
    LDAP_GROUP_DN = ''
    LDAP_USER_RDN_ATTR = 'uid'
    LDAP_USER_LOGIN_ATTR = 'uid'
    LDAP_BIND_USER_DN = None
    LDAP_BIND_USER_PASSWORD = None
    LDAP_ALWAYS_SEARCH_BIND = False
    LDAP_SEARCH_FOR_GROUPS = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
         'sqlite:///' + os.path.join(basedir, 'app.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    ENTRY_PER_PAGE = 24
