#!/bin/bash

yum -y install exim mailx

mkdir /root/SSL/mail.mydomain.com -p
cd /root/SSL/mail.mydomain.com

COUNTRY="US"               
STATE="Washington"        
LOCALITY="Seattle"        
ORGNAME="SCC"              
ORGUNIT="1"                 
HOSTNAME="Mail"
EMAIL="paulierev1775@mydomain.com" 
cat <<__EOF__ | openssl req -nodes -x509 -newkey rsa:2048 -keyout mail.mydomain.com.key -out mail.mydomain.com.crt -days 365
$COUNTRY
$STATE
$LOCALITY
$ORGNAME
$ORGUNIT
$HOSTNAME

$EMAIL
__EOF__

cp mail.mydomain.com.key mail.mydomain.com.crt /etc/ssl/
cp /etc/exim/exim.conf{,.orig}

yum -y install wget

####Then wget the exim config file: you can check the contents here:/etc/exim/exim.conf####

curl https://raw.githubusercontent.com/passwordlandia/ldap/master/startupscriptmaster/exim.conf > /etc/exim/exim.conf

systemctl start exim
systemctl status exim
systemctl enable exim

curl https://raw.githubusercontent.com/passwordlandia/ldap/master/startupscriptmaster/10-ssl.conf
curl https://raw.githubusercontent.com/passwordlandia/ldap/master/startupscriptmaster/10-auth.conf
curl https://raw.githubusercontent.com/passwordlandia/ldap/master/startupscriptmaster/10-mail.conf
curl https://github.com/passwordlandia/ldap/blob/master/startupscriptmaster/10-master.conf

systemctl start dovecot
systemctl status dovecot
systemctl enable dovecot

echo "test" | /usr/sbin/exim -v paulierev1775@mydomain.com

echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.142.0.2/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo
