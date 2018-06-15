#!/bin/bash

apt-get install -y nfs-client
apt-get install -y libpam-ldap nscd
apt-get install -y debconf-utils
apt-get install -y wget

export DEBIAN_FRONTEND=noninteractive

wget https://raw.githubusercontent.com/passwordlandia/ldap/master/startupscriptmaster/ldap_debconf

ldapip=$(gcloud compute instances list | grep ldap-server-a | awk '{ print $4 }' | tail -1) 

sed -i 's,ldap://(youriphere),ldap://"$ldapip",g' /ldap_debconf

while read line; do echo "$line" | debconf-set-selection; < ldap_debconf

sed -i 's/compat/compat ldap/g' /etc/nsswitch.conf

sed -i 's/PasswordAuthentication no/PasswordAuthentication Yes/g' /etc/ssh/sshd_config

/etc/init.d/nscd restart

nfsip=$(gcloud compute instances list | grep nfs-server | awk '{ print $4 }' | tail -1) 
showmount -e $nfsip

mkdir /mnt/test

echo "$nfsip:/var/nfsshare/testing /mnt/test nfs defaults 0 0" >> /etc/fstab 
mount -a
*profit*

echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.142.0.19/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo 
