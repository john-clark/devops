#!/bin/bash

# Test if Composer is installed
/home/vagrant/bin/composer.phar -v > /dev/null 2>&1
COMPOSER_INSTALLED=$?

echo ">>> check composer"
[[ $COMPOSER_INSTALLED -ne 0 ]] && { printf "!!! Composer is not installed.\n    Drupal installation aborted!\n"; exit 0; }

# Fix for symfony

#echo ">>> load .env"
#if [ ! -f .env ]; then
#  echo "no .env found"
#  exit 1
#else
#  set -o allexport
#  source ./.env
#  set +o allexport
#fi

#echo ">>> check needed variables"
#for VAR in INSTALL_DIR MYSQL_USER MYSQL_PASSWORD MYSQL_HOSTNAME MYSQL_PORT MYSQL_DATABASE SITE_DOMAIN SITE_EMAIL DRUPAL_EMAIL DRUPAL_USER DRUPAL_PASS
#do
#  eval VALUE=\$$VAR
#  if [ ! "$VALUE" ]; then
#    echo "!!! .env variable $VAR is not set"
#    exit 1;
#  fi
#done

if [[ -d /var/www/symfony.ubuntu.lan/vendor ]]; then
  echo "Symfony already Installed"
  exit 1;
fi

echo ">>> Install prereq for symfony demo"
sudo apt install -y php-sqlite3 | grep -P "\d\K upgraded" 

echo ">>> git clone symfony demo"
cd /var/www/symfony.ubuntu.lan
git clone https://github.com/symfony/demo.git . > /dev/null 2>&1

echo ">>> composer install symfony"
#valid versions
php /home/vagrant/bin/composer.phar install \
	--stability dev \
	--no-interaction \
	--no-ansi >>symfony-composer.log >>/var/www/symfony-drush.log 2>&1

php /home/vagrant/bin/composer.phar require symfony/apache-pack >>/var/www/symfony-drush.log 2>&1

php /home/vagrant/bin/composer.phar upgrade >>/var/www/symfony-drush.log 2>&1


echo ">>> Fix apache folders"
sudo sed -i 's/DocumentRoot.*/&\/public/g' /etc/apache2/sites-enabled/symfony.ubuntu.lan.conf
sudo sed -i 's/DocumentRoot.*/&\/public/g' /etc/apache2/sites-enabled/symfony.ubuntu.lan-ssl.conf

echo ">>> Restarting Webserver"
sudo systemctl restart apache2 php8.1-fpm

echo ">>> symfony install complete"
