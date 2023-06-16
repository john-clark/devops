#!/bin/bash
echo ">>> Installing Adminer web"
cd /var/www/html
mkdir adminer
cd adminer
#install for sqlite
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-en.php > /dev/null 2>&1

cat <<< '
<?php
function adminer_object() {
    foreach (glob("plugins/*.php") as $filename) { include_once "./$filename"; }
    $plugins = array(
        // specify enabled plugins here
	      new FCSqliteConnectionWithoutCredentials()
    );
    return new AdminerPlugin($plugins);
}
include "./adminer-4.8.1-en.php";
?>' > index.php
mkdir plugins
cd plugins
wget https://raw.githubusercontent.com/vrana/adminer/master/plugins/plugin.php > /dev/null 2>&1
wget https://raw.githubusercontent.com/FrancoisCapon/LoginToASqlite3DatabaseWithoutCredentialsWithAdminer/master/fc-sqlite-connection-without-credentials.php > /dev/null 2>&1
#now lets install mysql
cd ..
mkdir mysql
cd mysql
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql-en.php > /dev/null 2>&1
ln -s adminer-4.8.1-mysql-en.php index.php
#
echo ">>> READY"
echo "    For sqlite https://ubuntu.lan/adminer/"
echo "    use db: /var/www/symfony.ubuntu.lan/data/database.sqlite"
echo "    For mysql https://ubuntu.lan/adminer/mysql/"
echo "    use server: localhost username: root password: root db: drupal"