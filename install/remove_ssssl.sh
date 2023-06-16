#!/bin/bash
#
# remove self signed ssl site
#

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
        echo 'run with sudo'
        exit 1
fi
#check for command line options
if [[ -z "${1}" ]]; then
 echo "Need atleast the domain name"
 echo "Exmaple Useage \"sudo ./remove_ssssl.sh ubuntu.lan drupal \""
 exit 1
fi

#set vars to command line options
ROOTDOMAIN="${1}"
if [[ ! -z "${2}" ]]; then
  SUBDOMAIN="${2}."
fi

#fix if needed
DOMAIN="$SUBDOMAIN$ROOTDOMAIN"
#store certs in subfolder
SSL_DIR="/etc/ssl/$ROOTDOMAIN"

echo ">>> Removing $DOMAIN self-signed SSL"
if [[ -d "$SSL_DIR/" ]]; then
  echo ">> Found $SSL_DIR looking for keys"
  if [[ -f "$SSL_DIR/$DOMAIN.key" ]]; then
    rm "$SSL_DIR/$DOMAIN.key"
    rm "$SSL_DIR/$DOMAIN.crt"
  fi
  #check if folder is empty
  if [ x$(find "$SSL_DIR" -prune -empty) = x"$SSL_DIR" ]; then
    echo ">> $SSL_DIR empty removing"
    rmdir "$SSL_DIR"
  fi
fi
if [[ -f "/vagrant/$DOMAIN.crt" ]]; then
  rm "/vagrant/$DOMAIN.crt"
fi

echo ">>> Removing /var/www/$DOMAIN directory"
rm -rf /var/www/$DOMAIN

echo ">>> Removing /var/log/apache2/$DOMAIN directory"
rm -rf /var/log/apache2/$DOMAIN

echo "!!! make sure to run local-certificates.ps1 remove $DOMAIN on windows"

#disable sites
echo ">>> Disabling sites"
a2dissite $DOMAIN $DOMAIN-ssl

echo ">>> Restarting Webserver"
systemctl restart apache2 php8.1-fpm

echo ">>> Removing configs"
SITES_DIR="/etc/apache2/sites-available"
rm "$SITES_DIR/$DOMAIN.conf"
rm "$SITES_DIR/$DOMAIN-ssl.conf"
