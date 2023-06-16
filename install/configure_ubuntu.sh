#!/bin/bash

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
	echo 'run with sudo'
	exit 1
fi
export DEBIAN_FRONTEND=noninteractive

echo ">>> Setting Timezone & Locale"
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
apt-get install -qq language-pack-en | grep -P "\d\K upgraded"
locale-gen en_US > /dev/null
update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 > /dev/null

echo ">>> Updating System"
add-apt-repository -y universe > /dev/null
apt-get -y update > /dev/null

echo ">>> Installing Packages"
apt-get -y install </vagrant/install/packages.txt | grep -P "\d\K upgraded"

echo ">>> Installing Mail System"
debconf-set-selections <<< "postfix postfix/mailname string $(hostname -f)"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get -y install postfix mailutils | grep -P "\d\K upgraded"

#apt-get -y install software-properties-common | grep -P "\d\K upgraded"
apt-get -y upgrade | grep -P "\d\K upgraded"
