#!/bin/bash
set -e
set -o pipefail
#see if ubuntu is setup
 if [ ! -f /home/vagrant/setup-vbox.log ]; then
   echo ">>> installing guest additions"
   sudo /vagrant/install/install_vboxguestadd.sh 2>&1 | tee /home/vagrant/setup-vbox.log
   echo ">>> Stage 1 complete - Reboot now..."
   exit
 fi
#see if ubuntu is setup
if [ ! -f /home/vagrant/setup-centos.log ]; then
  echo ">>> installing centos"
  sudo /vagrant/install/configure_centos.sh 2>&1 | tee /home/vagrant/setup-centos.log
  #sudo /vagrant/install/configure_swap.sh 2>&1 | tee /home/vagrant/setup-centos.log
  echo ">>> Stage 2 complete - Reboot now..."
  exit
fi
# see if lamp is setup
if [ ! -f /home/vagrant/setup-lamp.log ]; then
  #sudo /vagrant/install/configure_apache.sh 2>&1 | tee /home/vagrant/setup-.log
  #sudo /vagrant/install/configure_mysql.sh 2>&1 | tee /home/vagrant/setup-lamp.log
  echo ">>> Stage 3 complete - Ready to Serve, import certificate now..."
  exit
fi
echo "Provisioning Complete"
