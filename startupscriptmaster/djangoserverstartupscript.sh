#!/bin/bash

yum install -y epel-release
yum update -y
yum install python-pip -y
sudo pip install virtualenv
sudo pip install --upgrade pip
yum install -y telnet

mkdir /opt/myproject
cd /opt/myproject

curl https://raw.githubusercontent.com/passwordlandia/ldap/master/startupscriptmaster/settings.py

sudo pip install virtualenv
virtualenv myprojectenv
source myprojectenv/bin/activate && pip install django psycopg2 && django-admin.py startproject myproject .

mv -f /opt/myproject/settings.py /opt/myproject/myproject/settings.py

source myprojectenv/bin/activate && python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8000

setenforce 0

echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.142.0.19/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo 
