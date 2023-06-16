#!/bin/bash

# Test if Composer is installed
/home/vagrant/bin/composer.phar -v > /dev/null 2>&1
COMPOSER_INSTALLED=$?

echo ">>> check composer"
[[ $COMPOSER_INSTALLED -ne 0 ]] && { printf "!!! Composer is not installed.\n    Drupal installation aborted!\n"; exit 0; }

echo ">>> load .env"
if [ ! -f .env ]; then
  echo "no .env found"
  exit 1
else
  set -o allexport
  source ./.env
  set +o allexport
fi

echo ">>> check needed variables"
for VAR in INSTALL_DIR MYSQL_USER MYSQL_PASSWORD MYSQL_HOSTNAME MYSQL_PORT MYSQL_DATABASE SITE_DOMAIN SITE_EMAIL DRUPAL_EMAIL DRUPAL_USER DRUPAL_PASS
do
  eval VALUE=\$$VAR
  if [ ! "$VALUE" ]; then
    echo "!!! .env variable $VAR is not set"
    exit 1;
  fi
done

if [[ -d drupal ]]; then
  echo "drupal exists"
  exit 1;
fi

echo ">>> composer install drupal"
#valid versions
php /home/vagrant/bin/composer.phar \
	create-project \
	drupal-composer/drupal-project:10.x-dev \
	$INSTALL_DIR \
	--stability dev \
	--no-interaction \
	--no-ansi >>/var/www/drupal-composer.log 2>&1

echo ">>> drush install site"
cd $INSTALL_DIR
vendor/drush/drush/drush si -y \
  --db-url=mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOSTNAME:$MYSQL_PORT/$MYSQL_DATABASE \
  --site-name=$SITE_DOMAIN \
  --site-mail=$SITE_EMAIL \
  --account-mail=$DRUPAL_EMAIL \
  --account-name=$DRUPAL_USER \
  --account-pass=$DRUPAL_PASS >>/var/www/drupal-drush.log 2>&1

echo ">>> Fix apache folders"
sudo sed -i 's/DocumentRoot.*/&\/web/g' /etc/apache2/sites-enabled/drupal.ubuntu.lan.conf
sudo sed -i 's/DocumentRoot.*/&\/web/g' /etc/apache2/sites-enabled/drupal.ubuntu.lan-ssl.conf

echo ">>> Restarting Webserver"
sudo systemctl restart apache2 php8.1-fpm

echo ">>> drupal install complete"
