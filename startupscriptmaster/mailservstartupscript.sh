#!/bin/bash

yum -y install exim mailx

mkdir /root/SSL/mail.mydomain.com -p
cd /root/SSL/mail.mydomain.com
openssl req -nodes -x509 -newkey rsa:2048 -keyout mail.mydomain.com.key -out mail.mydomain.com.crt -days 365
cp mail.mydomain.com.key mail.mydomain.com.crt /etc/ssl/

echo -e "Country Name (2 letter code) [XX]:us;Country Name (2 letter code) [XX]:us;/n
State or Province Name (full name) []:South Carolina;Locality Name (eg, city) [Default City]:us-east1-b;/n
Organization Name (eg, company) [Default Company Ltd]:My First Project;/n
Organizational Unit Name (eg, section) []:mailserver-final;/n
Common Name (eg, your name or your server's hostname) []:mailserver-final;/n
Email Address []:paulierev1775@gmail.com;"

cp /etc/exim/exim.conf{,.orig}

yum -y install wget

####Then wget the exim config file: you can check the contents here:/etc/exim/exim.conf####

wget https://raw.githubusercontent.com/passwordlandia/ldap/master/startupscriptmaster/exim.conf
mv -f /root/SSL/mail.mydomain.com/exim.conf /etc/exim/exim.conf

cd /root/SSL/mail.mydomain.com

systemctl start exim
systemctl status exim
systemctl enable exim

yum -y install dovecot

sed -i 's"ssl = required/ssl = yes"/g' /etc/dovecot/conf.d/10-ssl.conf
sed -i "ssl_cert = </etc/pki/dovecot/certs/dovecot.pem;ssl_cert = </etc/ssl/mail.mydomain.com.crt";/g' /etc/dovecot/conf.d/10-ssl.conf
sed -i "ssl_key = </etc/pki/dovecot/private/dovecot.pem;ssl_key = </etc/ssl/mail.mydomain.com.key";g' /etc/dovecot/conf.d/10-ssl.conf

sed -i 's/"#disable_plaintext_auth = yes/disable_plaintext_auth = no"/g' /etc/dovecot/conf.d/10-auth.conf
sed -i 's"auth_mechanisms = plain/auth_mechanisms = plain login"/g' /etc/dovecot/conf.d/10-auth.conf

sed -i "s;#mail_location = ;mail_location = maildir:~/Maildir;g" /etc/dovecot/conf.d/10-mail.conf

echo "service auth {
...
    unix_listener auth-client {
        mode = 0660
        user = exim
    }
}" >> /etc/dovecot/conf.d/10-master.conf

systemctl start dovecot
systemctl status dovecot
systemctl enable dovecot

echo "test" | /usr/sbin/exim -v paulierev1775@mailserv-test

###To test: echo "test" | /usr/sbin/exim -v nicolebade@mydomain.com where nicolebade@mydomain.com is your gcloud user,### 
###you should see exam working to deliver the message. It won't go through because of port blockage,### 
###but you'll be able to see it in the output of your command.###

###if you tail /var/log/exim/main.log you should see the mail attempting to be sent and timing out:###

###Complete this assignment by automating your build of the mail server.###
If you need help, don't hesitate to ask. Note that "wgeting" exim and dovecot config files is fine to complete the configuration.###
