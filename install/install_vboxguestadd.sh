#!/bin/bash
#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
        echo 'run with sudo'
        exit 1
fi
# reference: https://www.if-not-true-then-false.com/2010/install-virtualbox-guest-additions-on-fedora-centos-red-hat-rhel/

# get rid of the currently running kernel packages and install the new ones...
echo ">>> Cleaning Kernel"
yum remove -y kernel*`uname -r` >/dev/null 2>&1
echo ">>> Getting Kernel"
yum install -y kernel-devel kernel-headers gcc dkms make bzip2 perl libX11 >/dev/null 2>&1
ldconfig
NEW_UNAME=$(ls /usr/src/kernels/ | grep 'el6.x86_64')
# this command is to ensure the kernel's .config reaches the source directory the modules will be building.
cp -f /boot/config-$NEW_UNAME /usr/src/kernels/$NEW_UNAME/.config

VBOX_VERSION=7.0.0
cd /tmp
echo ">>> Getting vbox additions iso"
wget -N http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso >/dev/nul 2>&1
mount -o loop,ro VBoxGuestAdditions_$VBOX_VERSION.iso /media

# this will fail, but your helper binaries will be installed
echo ">>> Installing Addtions"
/media/VBoxLinuxAdditions.run --nox11 >/dev/nul 2>&1
# so we will now direct the helper binary to build for the kernel we want instead of
# the running one invalidly returned by `uname -r` inside of VirtualBox's .run binary.
/sbin/rcvboxadd quicksetup $NEW_UNAME >/dev/nul 2>&1

echo ">>> Complete unmounting media"
umount /media
