#!/bin/bash

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
	echo 'run with sudo'
	exit 1
fi

echo ">>> Configuring SWAP"
if free | awk '/^Swap:/ {exit !$2}'; then
	echo "Swap on"
else
	echo "Swap off"
	fallocate -l 1G /.swap
	chmod 600 /.swap
	mkswap /.swap
	swapon /.swap
	cp /etc/fstab /etc/fstab.bak
	echo '/.swap none swap sw 0 0' | tee -a /etc/fstab
	printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf && sysctl -p

	# Enable cachefilesd
	echo "RUN=yes" > /etc/default/cachefilesd
fi
