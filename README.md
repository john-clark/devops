# What is this?

---

**Purpose:** Create highly replicable development environment that closely mirrors a specified production environment.

**Deployment:** Vagrant Virtualbox (ubuntu/jammy64) LAMP server local developer machine hosting self-signed sites of drupal and symfony  

---

## How to use this?

1. Developers local .ssh setup with key in GitHub. 
    > *TODO* mirror ssh key to vm
2. Clone this repository or download/extract this repo
3. Run the ``install.ps1`` to setup 
   * workstation prerequisites
   * vagrant vm prerequisites 
   * VM sites and root certificates.
4. Once provisioning is done, the following sites should be available:
   * https://ubuntu.lan (OEM website)
     * https://ubuntu.lan/phpinfo.php
     * https://ubuntu.lan/server-info
     * https://ubuntu.lan/adminer/ (for no password sqlite)
     * https://ubuntu.lan/adminer/mysql
   * https://symfony.ubuntu.lan
   * https://drupal.ubuntu.lan
    > *TODO* Setup shared folders for workstation gui webdev (phpstorm/vscode)
5. To start over type ``uninstall.ps1`` to remove the vm and the local root certificates.
