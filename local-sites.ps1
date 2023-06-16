<#
.SYNOPSIS
    create, remove, list - websites on the vagrant host os
.DESCRIPTION
    help manage sites hosted on the vm
.PARAMETER Option
    Specifiy what to do
.EXAMPLE
    C:\PS> local-sites.ps1 -option add
    Adds *.crt to local certificate store and modifies the hosts file to add hostname.
    Changing add to remove will do the opposite
.EXAMPLE
    C:\PS> local-sites.ps1
    shows the certifcates found in the root store that are in the current directory
.OUTPUTS
    System.String
.NOTES
    Author: John Clark
    Date:   6/16/2023
#>

#get command line argument
    [CmdletBinding(DefaultParameterSetName = 'Option')]

param(
    [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'Argument'
    )]
    [ValidateSet(
            "add",
            "remove",
            "list",
            "help",
            "",
            IgnoreCase
    )]
    [AllowEmptyString()]
    [String]$Option
)
$Option = $Option.ToLower()

#see what sites are installed
$webdirs = @(foreach ($line in (cmd /c vagrant ssh -c "ls /var/www/" -- -q))
{
    $dirs = $line.split(" ");$dirs.Split('', [System.StringSplitOptions]::RemoveEmptyEntries)
})
#nothing to do yet
$reloadcerts = $false

switch ($Option)
{
    "add" {
        #checks on composer
        $composerbin = (cmd /c vagrant ssh -c "ls /home/vagrant/bin" -- -q)
        if ($composerbin -notcontains 'composer.phar')
        {
            Write-Host "Did not find composer installed, installing..."
            vagrant ssh -c 'cd /vagrant/install && sudo ./install-composer.sh'
        }
        else
        {
            Write-Host "Composer already installed"
        }
        #check on symfony
        if ($webdirs -notcontains 'symfony.ubuntu.lan')
        {
            write-host "Did not find symfony.ubuntu.lan installing..."
            vagrant ssh -c 'cd /vagrant/install && sudo ./create_ssssl.sh symfony.ubuntu.lan'
            vagrant ssh -c 'cd /vagrant/install && ./install-symfony.sh'
            $reloadcerts = $true
        }
        else
        {
            Write-Host 'symfony.ubuntu.lan already installed'
        }
        #check on drupal
        if ($webdirs -notcontains 'drupal.ubuntu.lan')
        {
            write-host "Did not find drupal.ubuntu.lan installing..."
            vagrant ssh -c 'cd /vagrant/install && sudo ./create_ssssl.sh drupal.ubuntu.lan'
            vagrant ssh -c 'cd /vagrant/install && ./install-drupal.sh'
            $reloadcerts = $true
        }
        else
        {
            Write-Host 'drupal.ubuntu.lan already installed'
        }
        #See if we need to import the certs and dns
        if ($reloadcerts -eq $true)
        {
            .\local-certificates.ps1 add
        }
    }
    "remove" {
        #checks
        if ($webdirs -contains 'symfony.ubuntu.lan')
        {
            write-host "Found symfony.ubuntu.lan uninstalling..."
            vagrant ssh -c 'cd /vagrant/install && sudo ./remove_ssssl.sh symfony.ubuntu.lan'
            $reloadcerts = $true
        }
        else
        {
            Write-Host 'symfony.ubuntu.lan already removed'
        }
        if ($webdirs -contains 'drupal.ubuntu.lan')
        {
            write-host "Found drupal.ubuntu.lan uninstalling..."
            vagrant ssh -c 'cd /vagrant/install && sudo ./remove_ssssl.sh drupal.ubuntu.lan'
            $reloadcerts = $true
        }
        else
        {
            Write-Host 'drupal.ubuntu.lan already removed'
        }
        #do we need to?
        if ($reloadcerts -eq $true)
        {
            .\local-certificates.ps1 remove
        }
    }
    "list" {
        Write-Host "Found the following sites"
        $webdirs
    }
    default {
        Write-Host "How to use:"
        Write-Host "  .\local-sites.ps1 {create|remove|list}"
    }
}

