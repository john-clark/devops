#!/bin/bash

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
 echo 'run with sudo'
 exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo ">>> Installing Webserver"
apt-get -y install \
 apache2-bin \
 apache2-data \
 apache2-utils \
 apache2 \
 certbot \
 | grep -P "\d\K upgraded"
#install sites

echo ">>> Installing PHP"
apt-get -y install \
 libapache2-mod-php \
 php-apcu \
 php-bz2 \
 php-common \
 php-curl \
 php-fpm \
 php-gd \
 php-intl \
 php-mbstring \
 php-mysql \
 php-soap \
 php-xml \
 php-xdebug \
 php-zip \
 libapache2-mod-php8.1 \
 php8.1-bz2 \
 php8.1-cli \
 php8.1-common \
 php8.1-curl \
 php8.1-fpm \
 php8.1-gd \
 php8.1-intl \
 php8.1-mbstring \
 php8.1-mysql \
 php8.1-opcache \
 php8.1-readline \
 php8.1-soap \
 php8.1-xml \
 php8.1-zip \
 php8.1 \
 php \
 | grep -P "\d\K upgraded"

echo ">>> enable modules"
a2enmod rewrite ssl proxy_fcgi setenvif actions | grep -P "\d\K enabled"
a2enconf php8.1-fpm | grep -P "\d\K enabled"

#recreate the ssl cert
DOMAIN="ubuntu.lan"
SSL_DIR="/etc/ssl/$DOMAIN"
PASSPHRASE="none"
SUBJ="
C=US
ST=IA
L=Ames
O=Development
OU=Local
CN=$DOMAIN
emailAddress=root@localhost
"
#by default clobber
echo ">>> Installing $DOMAIN self-signed SSL"
mkdir -p "$SSL_DIR"

openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
    -keyout "$SSL_DIR/$DOMAIN.key" -out "$SSL_DIR/$DOMAIN.crt" -extensions san -config \
    <(echo "[req]";
      echo distinguished_name=req;
      echo "[san]";
      echo subjectAltName = DNS:$DOMAIN,DNS:*.$DOMAIN
     ) \
    -subj "$(echo -n "$SUBJ" | tr "\n" "/")"

cp /etc/ssl/ubuntu.lan/ubuntu.lan.crt /vagrant/ubuntu.lan.crt

echo ">>> Configuring hosting"
# let .htaccess clobber apache config
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
#redirect http to https if not already
if ! grep "RewriteEngine" "/etc/apache2/sites-enabled/000-default.conf"; then
  sed -i "1 a RewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule (\.\*) https://%{HTTP_HOST}%{REQUEST_URI}\n" /etc/apache2/sites-enabled/000-default.conf
fi
#create and enable ssl site if not already
if [ ! -f "/etc/apache2/sites-enabled/000-default-ssl.conf" ]; then
  mv /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/000-default-ssl.conf
  sed -i "s/error\.log/ssl-error\.log/g" /etc/apache2/sites-available/000-default-ssl.conf
  sed -i "s/ssl\/certs/ssl/g" /etc/apache2/sites-available/000-default-ssl.conf
  sed -i "s/ssl\/private/ssl/g" /etc/apache2/sites-available/000-default-ssl.conf
  sed -i "s/access\.log/ssl-access\.log/g" /etc/apache2/sites-available/000-default-ssl.conf
  sed -i "s/ssl-cert-snakeoil/ubuntu\.lan\/ubuntu\.lan/g" /etc/apache2/sites-available/000-default-ssl.conf
  sed -i "s/lan\.pem/lan.crt/g" /etc/apache2/sites-available/000-default-ssl.conf
  a2ensite 000-default-ssl | grep -P "\d\K enabled"
fi

echo ">>> Creating phpinfo"
echo "<?php phpinfo();" >/var/www/html/phpinfo.php

echo ">>> Configuring server-info"
sed -i "s/Require/#Require/g" /etc/apache2/mods-available/info.conf
a2enmod info.load

echo ">>> Restarting Webserver"
systemctl restart apache2 php8.1-fpm

echo ">>> Installing Adminer"
/vagrant/install/install-adminer.sh

echo ">>> Configure www directory"
adduser vagrant www-data
chown -R www-data:www-data /var/www
chmod -R g+rwxs /var/www

