#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-install -y debconf-utils
wget https://raw.githubusercontent.com/passwordlandia/ldap/master/startupscriptmaster/ldap_debconf

while read line; do echo "$line" | debconf-set-selection; < ldap_debconf

apt-get -y install libpam-ldap nscd

sed -i 's/compat/compat ldap/g' /etc/nsswitch.conf

sed -i 's/PasswordAuthentication no/PasswordAuthentication Yes/g' /etc/ssh/sshd_config

/etc/init.d/nscd restart


#sed -i 's,uri ldapi:///,uri ldap://youriphere,g' /etc/ldap.conf

#sed -i 's/base dc=example,dc=net/base dc=nti310,dc=local/g' /etc/ldap.conf
