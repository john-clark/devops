#!/bin/bash
set -e
set -o pipefail
#see if ubuntu is setup
 if [ ! -f /home/vagrant/setup-vbox.log ]; then
   echo ">>> Removing seatbelts"
   sudo iptables --flush
   sudo iptables -P INPUT ACCEPT
   sudo iptables -P FORWARD ACCEPT
   sudo iptables -P OUTPUT ACCEPT
   sudo iptables -t nat -F
   sudo iptables -t mangle -F
   sudo iptables -F
   sudo iptables -X
   sudo service iptables save > /home/vagrant/setup-vbox.log 2>&1
   sudo iptables -S >> /home/vagrant/setup-vbox.log 2>&1
   sudo sed -i 's/SELINUX=enforcing/SELINUX=permisive/g' /etc/selinux/config
   echo ">>> installing guest additions"
   sudo /vagrant/install/install_vboxguestadd.sh >> /home/vagrant/setup-vbox.log 2>&1
   echo ">>> Stage 1 complete - Reboot now..."
   exit
 fi
#see if ubuntu is setup
if [ ! -f /home/vagrant/setup-centos.log ]; then
  echo ">>> installing centos - please wait..."
  sudo /vagrant/install/configure_centos.sh > /home/vagrant/setup-centos.log 2>&1
  echo ">>> installing extras"
  sudo chkconfig sendmail off >> /home/vagrant/setup-centos.log 2>&1
  sudo chkconfig httpd on >> /home/vagrant/setup-centos.log 2>&1
  #Todo setup fastcgi
  #https://tecadmin.net/setup-httpd-with-fastcgi-and-php-on-centos-redhat/
  echo ">>> Stage 2 complete - Reboot now..."
  exit
fi
#
if [ ! -f /home/vagrant/setup-extra.log ]; then
  sudo bash -c "echo '<?php phpinfo();' >/var/www/html/phpinfo.php"
  #Todo fix www permisions
  sudo yum install -y mysql-server >> /home/vagrant/setup-extra.log 2>&1
  sudo /sbin/chkconfig --levels 235 mysqld on >> /home/vagrant/setup-extra.log 2>&1
  sudo service mysqld start >> /home/vagrant/setup-extra.log 2>&1
  /usr/bin/mysqladmin -u root password 'password'
  /usr/bin/mysqladmin -u root -h centos password 'password'
  echo ">>> Stage 3 complete - Ready to Serve"
  exit
fi
echo "Provisioning Complete"
