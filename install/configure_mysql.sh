#!/bin/bash

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
 echo 'run with sudo'
 exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo ">>> Installing MySQL"
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

apt-get -y install \
 mysql-server \
 phpmyadmin \
 mysql-client-8.0 \
 mysql-client-core-8.0 \
 mysql-client \
 mysql-common \
 | grep -P "\d\K upgraded"

echo ">>> Configuring MySQL permissions"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# not secure but who cares!
mysql --defaults-extra-file=<(echo $'[client]\nuser=root\npassword=root') <<-SQL
  DELETE FROM mysql.user WHERE User LIKE 'root';
  CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
  GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
SQL

echo ">>> Restarting MySQL"
service mysql restart
