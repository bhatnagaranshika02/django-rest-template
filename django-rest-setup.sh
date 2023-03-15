#!/bin/bash
function mkfile() {
    mkdir -p -- "$1" && touch -- "$1"/"$2"
}

chmod +x ./django-rest-setup.sh

echo -n "Project name: "
read PROJECT_NAME
PROJECT_NAME_SRC=$PROJECT_NAME"_src"

mkdir $PROJECT_NAME
cd $PROJECT_NAME

python3 -m venv .venv
. .venv/bin/activate
pip install django djangorestframework

django-admin startproject $PROJECT_NAME_SRC .
python3 manage.py migrate

echo "Create super user:"
python3 manage.py createsuperuser

# mkdir apps
cd $PROJECT_NAME_SRC/ 
mkfile models index.py
mkfile views auth.py
mkfile tests index.py
mkfile serializers index.py

cd ..

echo "config settings.py ..."

SETTINGS_PATH="./$PROJECT_NAME_SRC/settings.py"
VIEWS_TEMPLATE="./$PROJECT_NAME_SRC/views/auth.py"
URLS_TEMPLATE="./$PROJECT_NAME_SRC/urls.py"

cat > $SETTINGS_PATH <<EOF
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/4.1/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-o%ezec$(@my4@=)$!yged!dxe72j@32n3b3ymv4)-6t9f!(_d-'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = [
    '$PROJECT_NAME_SRC',
    'rest_framework',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = '$PROJECT_NAME_SRC.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = '$PROJECT_NAME_SRC.wsgi.application'


# Database
# https://docs.djangoproject.com/en/4.1/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}


# Password validation
# https://docs.djangoproject.com/en/4.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/4.1/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/4.1/howto/static-files/

STATIC_URL = 'static/'

# Default primary key field type
# https://docs.djangoproject.com/en/4.1/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EOF


cat > $VIEWS_TEMPLATE <<EOF
from django.http import JsonResponse
import datetime

def signin(request):
    date = datetime.datetime.now()
    return JsonResponse({"token": date},safe=False)
EOF

cat > $URLS_TEMPLATE <<EOF
"""sjangooo_src URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from  $PROJECT_NAME_SRC.views import auth

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', auth.signin)
]
EOF


python3 manage.py migrate
python3 manage.py runserver