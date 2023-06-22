#!/bin/bash

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
	echo 'run with sudo'
	exit 1
fi

#echo ">>> Setting Timezone & Locale"
cp /etc/localtime /root/oem.timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime

echo ">>> Setting up Reopos"
yum install -y https://rpms.remirepo.net/enterprise/remi-release-6.rpm
#yum-config-manager --enable remi-php71

#echo ">>> Updating System"
yum update -y

#echo ">>> Installing Packages"
yum install -y $(cat /vagrant/install/packages.txt)

echo ">>> Complete CentOS Configuration"
