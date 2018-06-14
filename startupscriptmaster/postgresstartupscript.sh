#!/bin/bash

yum install -y epel-release
yum update -y
yum install -y python-pip python-devel gcc postgresql-server postgresql-devel postgresql-contrib

postgresql-setup initdb

systemctl enable postgresql
systemctl start postgresql

yum -y install wget

cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.bak

wget https://raw.githubusercontent.com/passwordlandia/ldap/master/sqlfile.sql
wget https://raw.githubusercontent.com/passwordlandia/ldap/master/pg_hba.conf

sudo -i -u postgres psql -U postgres -f /sqlfile.sql
sudo -i -u postgres psql -U postgres -d template1 -c "ALTER USER postgres WITH PASSWORD 'postgres';"
mv pg_hba.conf /var/lib/pgsql/data/pg_hba.conf

systemctl restart postgresql

yum -y install phpPgAdmin

setenforce 0

sed -i 's/Require local/Require all granted/g' /etc/httpd/conf.d/phpPgAdmin.conf
sed -i 's/Allow from 127.0.0.1/Allow from all/g' /etc/httpd/conf.d/phpPgAdmin.conf
sed -i '/extra_login_security/ s/true/false/g' /etc/phpPgAdmin/config.inc.php
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf

systemctl restart postgresql.service
systemctl enable httpd
systemctl start httpd

setenforce 0
