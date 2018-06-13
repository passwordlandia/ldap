#!/bin/bash

###1. Install Dependencies###

yum install epel-release -y
yum update -y
yum install python-pip -y
sudo pip install --upgrade pip
yum install nginx -y
yum install wget -y

yum install python34-devel gcc -y
curl -O https://bootstrap.pypa.io/get-pip.py
/usr/bin/python3.4 get-pip.py

pip install virtualenv
mkdir -p /var/www && cd /var/www
virtualenv -p python3 p3venv

###2. Configurations###

echo -e "#the upstream component NGINX needs to connect to
upstream django {
    server unix:/run/uwsgi/cioenglish.sock;
}

# configuration of the server
server {
    listen        80;
    server_name     cioenglish.com;
    charset        utf-8;
    # max upload size
    client_max_body_size 75M;
    # Django media & static
    location /media  {
        alias /var/www/cioenglish/public/media;
    }
    location /static {
        alias /var/www/cioenglish/public/static;
    }
    # Finally, send all non-media requests to the Django server.
    location / {
        uwsgi_pass  django;
        include uwsgi_params;
        
        uwsgi_param Host $host;
        uwsgi_param X-Real-IP $remote_addr;
        uwsgi_param X-Forwarded-For $proxy_add_x_forwarded_for;
        uwsgi_param X-Forwarded-Proto $http_x_forwarded_proto;
    }
" > /etc/nginx/conf.d/cioenglish.conf

cd /var/www
source p3venv/bin/activate
pip install uwsgi
pip install django
pip install django psycopg2

systemctl start nginx

cd /var/www
django-admin.py startproject cioenglish &

cd cioenglish

cd cioenglish

wget https://raw.githubusercontent.com/passwordlandia/ldap/master/loadbalancer/settings.py

mv -f /var/www/cioenglish/cioenglish/settings.py.1 /var/www/cioenglish/cioenglish/settings.py

cd ..

python manage.py migrate

python manage.py runserver 0.0.0.0:8000 &

uwsgi --http :8000 --module cioenglish.wsgi &

useradd -s /bin/false -r uwsgi

echo "[uwsgi]
# Django-related settings
# the base directory (full path)
chdir = /var/www/cioenglish
# Django's wsgi file
module =cioenglish.wsgi
# the virtualenv (full path)
home = /var/www/p3venv
# Logs
logdate = True
logto = /var/log/uwsgi/access.log
# process-related settings
# master
master = true
# maximum number of worker processes
processes = 5
# the socket (use the full path to be safe)
socket = /run/uwsgi/cioenglish.sock
# ... with appropriate permissions - may be needed
chmod-socket = 666
# clear environment on exit
vacuum = true" > /var/www/cioenglish/cioenglish_uwsgi.ini

/var/www/p3venv/bin/uwsgi --emperor /etc/uwsgi/vassals &

echo "[Unit]
Description=uWSGI Emperor service
[Service]
ExecStartPre=/usr/bin/bash -c 'mkdir -p /run/uwsgi; chown uwsgi:nginx /run/uwsgi'
ExecStart=/var/www/p3venv/bin/uwsgi --emperor /etc/uwsgi/vassals
Restart=always
KillSignal=SIGQUIT
Type=notify
NotifyAccess=all
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/uwsgi.service

systemctl stop nginx
systemctl start uwsgi
systemctl start nginx
