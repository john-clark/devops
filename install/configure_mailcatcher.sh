#!/usr/bin/env bash

# this is a work in progress
# https://mailcatcher.me/
# TODO fix init to systemd https://gist.github.com/socketz/b370bfe0331f868b6bd9e6a878096575

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
        echo 'run with sudo'
        exit 1
fi

# Test if PHP is installed
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".") || {echo 'php not installed' ; exit 1; }

# Test if Apache is installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

echo ">>> Installing Mailcatcher"

# Installing dependency
# -qq implies -y --force-yes
sudo apt-get install -qq libsqlite3-dev ruby-dev aptitude build-essential software-properties-common || { echo 'install prereqs failed' ; exit 1; }

if $(which rvm) -v > /dev/null 2>&1; then
	echo ">>>>Installing with RVM"
	$(which rvm) default@mailcatcher --create do gem install --no-rdoc --no-ri mailcatcher
	$(which rvm) wrapper default@mailcatcher --no-prefix mailcatcher catchmail
else
	# Gem check
	if ! gem -v > /dev/null 2>&1; then sudo aptitude install -y libgemplugin-ruby; fi

	# Install
	gem install --no-rdoc --no-ri mailcatcher
fi

# Make it start on boot
if [ ! -f /etc/init/mailcatcher.conf ]; then
sudo tee /etc/init/mailcatcher.conf <<EOL
description "Mailcatcher"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

exec /usr/bin/env $(which mailcatcher) --foreground --http-ip=0.0.0.0
EOL

# Start Mailcatcher
sudo service mailcatcher start
fi

if [[ $PHP_IS_INSTALLED -eq 0 ]]; then
    # Make php use it to send mail
    echo "sendmail_path = /usr/bin/env $(which catchmail)" | sudo tee /etc/php/${PHP_VERSION}/mods-available/mailcatcher.ini
    sudo phpenmod mailcatcher
    sudo service php${PHP_VERSION}-fpm restart
fi

if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then
    sudo service apache2 restart
fi
