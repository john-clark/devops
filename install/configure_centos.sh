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

echo ">>> Setting up Repositories"
yum install -y https://rpms.remirepo.net/enterprise/remi-release-6.rpm
yum-config-manager --enable remi-php73
yum-config-manager --enable remi-safe

#echo ">>> Updating System"
yum update -y >/dev/nul 2>&1

#echo ">>> Installing Packages"
yum install -y $(cat /vagrant/install/packages.txt)

echo ">>> Complete CentOS Configuration"
