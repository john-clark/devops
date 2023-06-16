#!/bin/bash
set -e
set -o pipefail
#see if ubuntu is setup
if [ ! -f /home/vagrant/setup-ubuntu.log ]; then
  sudo /vagrant/install/configure_ubuntu.sh 2>&1 | tee /home/vagrant/setup-ubuntu.log
  sudo /vagrant/install/configure_swap.sh 2>&1 | tee /home/vagrant/setup-ubuntu.log
  echo "Reboot now..."
  exit
fi
# see if lamp is setup
if [ ! -f /home/vagrant/setup-lamp.log ]; then
  sudo /vagrant/install/configure_apache.sh 2>&1 | tee /home/vagrant/setup-lamp.log
  sudo /vagrant/install/configure_mysql.sh 2>&1 | tee /home/vagrant/setup-lamp.log
  echo "Ready to Serve. Import certificate now..."
  exit
fi
echo "Provisioning Complete..."
