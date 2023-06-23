# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/centos6"
  config.vm.boot_timeout = 300

  config.vm.synced_folder ".", "/vagrant"

  config.vm.hostname = 'centos'

  config.vm.network 'private_network', 
    ip: '172.16.0.9', 
    auto_config: false

#  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.memory = "8192"
    vb.cpus = "8"
    #vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    #vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

  end

  config.ssh.forward_agent = true
 
  config.vm.provision "shell",
    privileged: true,
	inline: <<-SHELL
        sudo /vagrant/install/provision.sh
  SHELL

  config.vm.provision :shell do |shell|
    shell.privileged = true
    shell.inline = 'echo rebooting'
    shell.reboot = true
  end

  config.vm.provision "shell", 
    privileged: true,
    inline: <<-SHELL
      mount -t vboxsf vagrant /vagrant/
      /vagrant/install/provision.sh
    SHELL

  config.vm.provision :shell do |shell|
    shell.privileged = true
    shell.inline = 'echo rebooting'
    shell.reboot = true
  end

  config.vm.provision "shell",
    privileged: true,
    inline: <<-SHELL
      mount -t vboxsf vagrant /vagrant/
      /vagrant/install/provision.sh
    SHELL
  
  config.vm.provision "shell", privileged: false, inline: <<-EOF
    echo "Vagrant Box provisioned!"
  EOF

end
