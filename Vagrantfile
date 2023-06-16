# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.boot_timeout = 300

  config.vm.define 'ubuntu' do |ubuntu|
    ubuntu.vm.hostname = 'ubuntu'
    ubuntu.vm.network :private_network, ip: '172.16.0.10'
  end

  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.memory = "8192"
    vb.cpus = "8"
  end

  config.ssh.forward_agent = true
  
  config.vm.provision "shell", inline: <<-SHELL
    sudo /vagrant/install/provision.sh
  SHELL

  config.vm.provision :shell do |shell|
    shell.privileged = true
    shell.inline = 'echo rebooting'
    shell.reboot = true
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo /vagrant/install/provision.sh
  SHELL

  config.vm.provision "shell", privileged: false, inline: <<-EOF
    echo "Vagrant Box provisioned!"
    echo "ready to run local-sites.ps1 add"
  EOF

end
