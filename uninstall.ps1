Write-Host "Press c to continue, any other key to abort..."

$key = [console]::ReadKey()
if ($key.Key -ne 'c') {
	exit
}
Write-Host ">>> Destroying Vagrant VM"
vagrant destroy -f
Remove-Item .vagrant -recurse -force

Write-Host ">>> Clearing old certs"
.\local-certificates.ps1 remove
Remove-Item *.crt
