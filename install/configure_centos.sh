#!/bin/bash

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
	echo 'run with sudo'
	exit 1
fi

echo ">>> Setting Timezone & Locale"
timedatectl set-timezone America/Chicago
#localectl set-local LANG=

echo ">>> Updating System"
yum -y update > /dev/null

echo ">>> Installing Packages"
yum -y install </vagrant/install/centos7_packages.txt | grep -P "\d\K upgraded"

echo ">>> Installing Mail System"

#apt-get -y install software-properties-common | grep -P "\d\K upgraded"
yum -y upgrade | grep -P "\d\K upgraded"
