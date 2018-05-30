#!/bin/bash

yum install -y epel-release
yum update -y
yum install -y python-pip python-devel gcc postgresql-server postgresql-devel postgresql-contrib

postgresql-setup initdb
systemctl enable postgresql
systemctl start postgresql

cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.bak

sed -i 's/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf
sed -i 's/#listen_addresses = 'localhost'/listen_addresses = '*'/g' /var/lib/pgsql/data/postgresql.conf
sudo systemctl enable postgresql
sudo systemctl restart postgresql

sudo yum install -y wget

wget https://raw.githubusercontent.com/passwordlandia/ldap/master/sqlfile.sql

sudo -i -u postgres psql -U postgres -f /sqlfile.sql

###You are done. If you want to test this environment, SSH into the server and type 
###sudo systemctl status postgresql####

yum -y install phpPgAdmin

setenforce 0

sed -i 's/Require local/Require all granted/g' /etc/httpd/conf.d/phpPgAdmin.conf

sed -i '/extra_login_security/ s/true/false/g' /etc/phpPgAdmin/config.inc.php

systemctl restart postgresql.service

sudo -i -u postgres psql -U postgres -d template1 -c "ALTER USER postgres WITH PASSWORD 'postgres';"

sed -i '/^local/ s/peer/md5/g' /var/lib/pgsql/data/pg_hba.conf

service postgresql restart
systemctl enable httpd
systemctl start httpd
