#!/bin/bash
#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
        echo 'run with sudo'
        exit 1
fi

#
if [ ! -f "/home/vagrant/bin/composer.phar" ]; then 
  apt-get update | grep -P "\d\K upgraded"
  apt-get -y install curl php-cli php-mbstring git unzip | grep -P "\d\K installed"
  if [[ ! -f "composer-setup.php" ]]; then
     php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  fi

  #
  HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
  HASHFILE=$(php -r "echo hash_file('SHA384','composer-setup.php');")
  RESULT=$(php -r "if ('$HASHFILE' === '$HASH') { echo 'verified'; } else { echo 'corrupt'; }")
  if [ "$RESULT" != "verified" ]; then
     echo "Installer corrupted";
     exit 1;
  else
     [ ! -d "/home/vagrant/bin" ] && mkdir "/home/vagrant/bin"
     php composer-setup.php --install-dir="/home/vagrant/bin"
  fi
  rm composer-setup.php
else
  ALIAS_STRING="alias composer=/home/vagrant/bin/composer.phar"
  ALIAS_FILE="/home/vagrant/.bash_aliases"
  [ ! -f "$ALIAS_FILE" ] && touch $ALIAS_FILE
  grep -q -x -F "$ALIAS_STRING" "$ALIAS_FILE" || echo $ALIAS_STRING>>$ALIAS_FILE
fi
echo "if running interactive: source ~/.profile"
