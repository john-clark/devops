#install_nfs.ps1 --NOT TESTED--
Write-Output "Starting Install"
$IsElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not($IsElevated)) {
    Write-Output "Rerunning Elevated"
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
        # now map w to nfs
        New-PSDrive W -PSProvider FileSystem -Root \\172.16.0.10\srv\nfs -Persist
        Write-Host "Completed Install"
      }             
   }
} else {
    $FeatureName = 'ClientForNFS-Infrastructure'
    if((Get-WindowsOptionalFeature -FeatureName $FeatureName -Online).State -eq "Enabled") {
        Write-Output "Already Installed"
    } else {
        Write-Output "Elevated install starting"
        Enable-WindowsOptionalFeature -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart
        #set nfs to use id 33 which matches www-data on the vm
        New-ItemProperty HKLM:SOFTWAREMicrosoftClientForNFSCurrentVersionDefault -Name AnonymousUID -Value 33 -PropertyType "DWord"
        New-ItemProperty HKLM:SOFTWAREMicrosoftClientForNFSCurrentVersionDefault -Name AnonymousGID -Value 33 -PropertyType "DWord"
        #restart nfs
        net stop nfsclnt
        net stop nfsrdr
        net start nfsrdr 
        net start nfsclnt

        #install nfs on the vm
        vagrant ssh -c 'sudo apt -y install nfs-kernel-server'
        vagrant ssh -c 'sudo echo /var/www 172.16.0.0/16(rw,all_squash,no_subtree_check,anonuid=33,anongid=33,sync) >>/etc/exports'
        vagrant ssh -c 'sudo systemctl start nfs-server.service'
    }
    Write-Output "Elevated install complete"

    Write-Host "Press any key to exit..."
    $key = [console]::ReadKey()
}
