#!/bin/bash
set -e
set -o pipefail
#see if ubuntu is setup
 if [ ! -f /home/vagrant/setup-vbox.log ]; then
   echo ">>> installing guest additions"
   sudo /vagrant/install/install_vboxguestadd.sh > /home/vagrant/setup-vbox.log 2>&1
   echo ">>> Stage 1 complete - Reboot now..."
   exit
 fi
#see if ubuntu is setup
if [ ! -f /home/vagrant/setup-centos.log ]; then
  echo ">>> installing centos"
  sudo /vagrant/install/configure_centos.sh > /home/vagrant/setup-centos.log 2>&1
  #sudo /vagrant/install/configure_swap.sh 2>&1 | tee /home/vagrant/setup-centos.log
  sudo chkconfig httpd on > /home/vagrant/setup-centos.log 2>&1
  # /etc/init.d/httpd start
  echo ">>> Stage 2 complete - Reboot now..."
  exit
fi
#
if [ ! -f /home/vagrant/setup-extra.log ]; then
  sudo service network restart > /home/vagrant/setup-extra.log 2>&1
  #sudo /vagrant/install/configure_apache.sh 2>&1 | tee /home/vagrant/setup-.log
  echo ">>> Stage 3 complete - Ready to Serve"
  exit
fi
echo "Provisioning Complete"
