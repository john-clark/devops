# Manual Installation Walkthrough

---

## TO BRING UP THE VM 

1. install choco > run in elevated powershell
   ```powershell 
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. install prereqs > in same elevated powershell
   ```powershell
   choco install vagrant vim git virtualbox
   ```

3. **REBOOT** 

   > **NOTE** <mark>*\*ENSURE VT is enabled in bios*\*</mark>


4. create folder for vagrant machines > in your user powershell
   ```powershell
   #folder where vm files will be stored/shared
   mkdir devops
   cd devops
   ```

5. create vagrant definition for vm > in your user powershell
   
   > ``notepad Vagrantfile``
   >
   >  ```vagrantfile
   >  Vagrant.configure("2") do |config|
   >    config.vm.box = "ubuntu/jammy64"
   >    config.vm.network "forwarded_port", guest: 80, host:80
   >  end
   >  ```
   > *This is extremely simplified for illustration purposes.*
   
6. Run  > in your user powershell
   ```
   vagrant up
   ```

   > **Note**
   > If you have ERROR starting vagrant, update to Vagrant to 2.3.6 or above 
   > or use the **ERROR FIX** of replacing the broken ruby file
   > ``C:\HashiCorp\Vagrant\embedded\gems\gems\vagrant-2.3.5\lib\vagrant\util\file_mutex.rb`` with 
   > [file_mutex.rb](https://github.com/chrisroberts/vagrant/blob/1f26256680a5bc4c78a8e14187aa8a0b926119be/lib/vagrant/util/file_mutex.rb)

7. Ready for use
   > #### Ubuntu VM should now be running

## TO CONFIGURE THE VM

1. SSH to the vm > in your powershell
   ```powershell
   vagrant ssh
   ```
2. Run provisioning script > on the vm
   ```bash
   #installs system updates and sets up swap needed for mysql
   sudo /vagrant/install/provision.sh
   ```
3. **REBOOT** > on the vm
   ```bash
   sudo reboot
   ```

4. SSH back into to the vm > in your powershell
   ```powershell
   vagrant ssh
   ```
   
5. Run provisioning script, yes again > on the vm
   ```bash
   #sets up apache and mysql (Note: ssl will be added below)
   sudo /vagrant/install/provision.sh
   ```
6. Install composer  > on the vm
   ```bash
   #puts in ~/bin/composer.phar
   sudo /vagrant/install//install-composer.sh
   ```
7. Install Symfony > on the vm
   ```bash
   #create the apache webfolder and certs
   sudo /vagrant/install/create_ssssl.sh symfony.ubuntu.lan
   #install symfony demo
   /vagrant/install/install-symfony.sh
   ```
8. Install Drupal > on the vm
   ```bash
   #create the apache webfolder and certs
   sudo /vagrant/install/create_ssssl.sh drupal.ubuntu.lan
   #install drupal
   /vagrant/install/install-drupal.sh
   ```
9. Log out of SSH > on the vm
   ```bash
   exit
   ```

10. Update local computer root certificates > in your powershell
   ```powershell
   local-certificates.ps1 add
   ```
11. Ready for use  > in your powershell
   >#### Websites now online and signed
   > * start firefoox https://ubuntu.lan
   > * start chrome https://symfony.ubuntu.lan
   > * start explorer https://drupal.ubuntu.lan

## To create additional sites:

1. On the Ubuntu VM: ``sudo /vagrant/install/create_ssssl.sh something.ubuntu.lan``
2. On the User local machine ``local-certificates.ps1 add`` to import ssl
3. Add content on the Ubuntu VM: ``/var/www/something.ubuntu.lan/``
   > **Note** See the ``install-symfony.sh`` script for more details 
