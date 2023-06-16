<#
.SYNOPSIS
    add, remove, list - file certificates to the local store and hostsnames added to hosts file for devops
.DESCRIPTION
    help manage localmachine root certificate store and hosts file using crt files in the current directory
.PARAMETER Option
    Specifiy what to do
.EXAMPLE
    C:\PS> local-certificate.ps1 -option add 
    Adds *.crt to local certificate store and modifies the hosts file to add hostname.
    Changing add to remove will do the opposite
.EXAMPLE
    C:\PS> local-certificate.ps1
    shows the certifcates found in the root store that are in the current directory
.OUTPUTS
    System.String
.NOTES
    Author: John Clark
    Date:   5/15/2023    
#>

[CmdletBinding(DefaultParameterSetName = 'Option')]

param(
    [Parameter(
            Position = 0,
            ParameterSetName = 'Option')
    ]
    [ValidateSet('add', 'remove', 'list', '', IgnoreCase)]
    [AllowEmptyString()]
    [string]$Option
)
$IsElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Edit-TrustedRootMachineCertificate($certificate)
{
    $store = get-item Cert:\LocalMachine\Root;
    $store.Open("MaxAllowed")
    #get host file each iteration in case it changed
    $HostsFileContent = Get-Content $env:windir\System32\drivers\etc\hosts

    if ($Option -cmatch 'list')
    {
        if ($store.Certificates.Find("FindByThumbprint", $certificate.Thumbprint, $true).Count -eq 1)
        {
            if ($HostsFileContent -match "`t$CertFileName")
            {
                ForEach ($line in $HostsFileContent)
                {
                    if ($line -match "`t$CertFileName")
                    {
                        Write-Host $line
                    }
                }
            }
            else
            {
                Write-Host "$CertFilename not found in hosts file"
            }
            Write-Host "------------------------------------------------------------------------------------------"
            Write-Host $certificate;
        }
        else
        {
            ForEach ($line in $HostsFileContent)
            {
                if ($line -match "`t$CertFileName")
                {
                    Write-Host "Found dns: $line, in hosts file without certificate installed."
                }
            }
            Write-Host "Cert File: $CertFileName, NOT FOUND in certificate store."
        }
    }
    elseif ( $Option -cmatch 'add' )
    {
        if ($store.Certificates.Find("FindByThumbprint", $certificate.Thumbprint, $false).Count -eq 0)
        {
            if ($IsElevated)
            {
                $store.Add($certificate);
                if ($null -eq (Select-String -Path $env:windir\System32\drivers\etc\hosts -Pattern "`t$CertFileName"))
                {
                    Write-Output "Updating hosts file"
                    # TODO: will have to figure out ip but for now use known set ip
                    Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "172.16.0.10`t$CertFileName" -Force
                }
                else
                {
                    Write-Output "$CertFileName exists in hosts file already"
                }
                Write-Host "Added root certificate: $CertFilename";
            }
            else
            {
                #rerun as admin
                $proc = Start-Process powershell -WorkingDirectory $PSScriptRoot -Verb runAs -PassThru -ArgumentList "-noprofile -file $PSCommandPath add"
                $proc.WaitForExit()
                if ($proc.ExitCode -ne 0)
                {
                    Write-Warning "$_ exited with status code $( $proc.ExitCode )"
                    Exit
                }
                else
                {
                    Write-Host "Success"
                }
                exit
            }
        }
        else
        {
            Write-Host "Already added root certificate: $CertFileName";
            if ($HostsFileContent -match "`t$CertFileName")
            {
                ForEach ($line in $HostsFileContent)
                {
                    if ($line -match "`t$CertFileName")
                    {
                        Write-Host "Found this line in hosts file:  $line"
                    }
                }
            }
            else
            {
                Write-Host "$CertFilename not found in hosts file"
            }
        }
    }
    elseif ( $Option -cmatch 'remove' )
    {
        if ($store.Certificates.Find("FindByThumbprint", $certificate.Thumbprint, $true).Count -eq 1)
        {
            if ($IsElevated)
            {
                if (Select-String -Path $env:windir\System32\drivers\etc\hosts -Pattern "`t$CertFileName")
                {
                    Write-Output "Removing $CertFileName from hosts file"
                    # TODO: will have to figure out ip but for now use known set ip
                    $NewHostsFileContent = Get-Content $HostFile | Where-Object {$_ -notmatch $CertFileName}
                    $NewHostsFileContent | Out-File $HostFile -enc ascii -Force
                }
                else
                {
                    Write-Output "$CertFileName does not exist in hosts file"
                }
                $store.Remove($certificate);
                Write-Host "Removed root certificate $CertFilename from store.";
            }
            else
            {
                #rerun as admin
                $proc = Start-Process powershell -WorkingDirectory $PSScriptRoot -Verb runAs -PassThru -ArgumentList "-noprofile -file $PSCommandPath remove"
                $proc.WaitForExit()
                if ($proc.ExitCode -ne 0)
                {
                    Write-Warning "$_ exited with status code $( $proc.ExitCode )"
                    Exit
                }
                else
                {
                    Write-Host "Success"
                }
            }
        }
        else
        {
            Write-Host "Root Certificate NOT found: $CertFileName";
            if (Select-String -Path $env:windir\System32\drivers\etc\hosts -Pattern "`t$CertFileName")
            {
                Write-Output "Found $CertFileName in hosts file, removing..."
                # TODO: will have to figure out ip but for now use known set ip
                $NewHostsFileContent = Get-Content $HostFile | Where-Object {$_ -notmatch $CertFileName}
                $NewHostsFileContent | Out-File $HostFile -enc ascii -Force
            }
            else
            {
                Write-Output "$CertFileName does not exist in hosts file"
            }
        }
    }
    else
    {
        Write-Host "How to use:"
        Write-Host "  .\local-certificate.ps1 {add|remove|list}"
        Exit
    }
    $store.Close();
}
#some basics
$HostFile = "$env:windir\System32\drivers\etc\hosts"
$currentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;

#look for certs in local folder
$files = Get-ChildItem "$currentDir" -Filter "*.crt"
if ($files.Count -eq 0)
{
    Write-Host "no .crt files found"
    #show hosts here
}
else
{
    foreach ($file in $files)
    {
        $CertFileName = $file -replace ".crt"
        $certfile = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($file.FullName);
        Edit-TrustedRootMachineCertificate -certificate $certfile;
    }
}
