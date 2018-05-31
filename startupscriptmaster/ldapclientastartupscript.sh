#!/bin/bash

apt-get --yes install libpam-ldap nscd

sed -i -r 's " 
/etc/init.d/nscd restart

sed -i -r 's /etc/ssh/sshd_config "PasswordAuthentication/no PasswordAuthentication/yes" g'

/etc/init.d/ssh restart

#sed -i 's,uri ldapi:///,uri ldap://youriphere,g' /etc/ldap.conf

#sed -i 's/base dc=example,dc=net/base dc=nti310,dc=local/g' /etc/ldap.conf
