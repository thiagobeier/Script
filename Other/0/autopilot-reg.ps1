Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Confirm:$false
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -Type Directory -Path "C:\HWID"
Set-Location -Path "C:\HWID"
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false
Get-WindowsAutopilotInfo -OutputFile "$env:COMPUTERNAME.csv"