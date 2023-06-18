#install.ps1
Write-Output "Starting Install"
#check if elevated
$IsElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not($IsElevated)) {
    Write-Output "Not elevated doing user install"

    #if vagrant installed assume we don't need prereqs. To test: choco uninstall vagrant
    $testgit = Get-Command "vagrant" -ErrorAction SilentlyContinue
    if($testgit) {
        Write-Output "Found git, assuming prerequisites are installed"
        vagrant up
	#.\local-certificates.ps1 add
        Write-Output "Install Complete"
    #    Write-Output " start firefox https://ubuntu.lan/"
	Write-Output ""
	#Write-Output "Installing Sub Sites"
	#.\local-sites.ps1 add
        Exit
    } else {
        Write-Output "No vagrant found, rerunning as elevated"

		if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
		  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
		  $proc = Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine -PassThru
          $handle = $proc.Handle # cache proc.Handle
          $proc.WaitForExit();
          #check to see if fail (permissions error)
          if ($proc.ExitCode -ne 0) {
                  Write-Warning "$_ exited with status code $($proc.ExitCode)"
                  Exit
          } else {
              $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.." 
              Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
              refreshenv | out-null #choco command
              Write-Output "Prereqs installed and evironment refreshed - rerun installer now"
          }             
       }
    }       
} else {
    Write-Output "Running in Elevated Prompt for Prerequisits install"
	# install choco
	Write-Output "Setting up DevOps Workstation requirements"
	$testchoco = Get-Command "choco" -ErrorAction SilentlyContinue
	if (-not($testchoco)) {
	  Write-Output "Chocolatey is not installed, installing now"
	  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
	} else {
		Write-Output "Chocolatey already installed"
	}
	# install packages
	$Packages = 'vim', 'git', 'vagrant', 'virtualbox'
	ForEach ($PackageName in $Packages)
	{
	  $testPackageName = Get-Command $PackageName -ErrorAction SilentlyContinue
	  if (-not($testPackageName)) {
		  Write-Output "Installing $PackageName"
		 choco install $PackageName -y
	  } else { 
		  Write-Output "$PackageName already installed" } 
	}
	Write-Output "Elevated install complete"

}
