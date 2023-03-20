############################################################################################################################################################################################################################################### 
# Author Thiago Beier thiago.beier@gmail.com    
# Version: 1.0 - 2020-04-30   
#
# Check if an user had been removed from source groups and remove it from security group
# Group A - has users, Group B - has users and those users (from Group A and B are added to Group C)
# This script checks if one of the users had been removed from Group A or B and remove it from Group C
# User can't ever be on Group A and B at the same time (those groups are used for Office 365 license assignment)
#
# Toronto, CANADA    
# Email: thiago.beier@gmail.com  
# https://www.linkedin.com/in/tbeier/  
# https://twitter.com/thiagobeier 
# https://thiagobeier.wordpress.com 

###############################################################################################################################################################################################################################################   

#Uncomment this line if you're setting this up on Windows 2016/2019 Server
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

#Uncoment the following lines to install, update all modules
Install-Module SharePointPnPPowerShellOnline -Force
Install-Module -Name MicrosoftTeams -Force
Install-Module -Name AzureAD -Force
Install-Module MSOnline -Force
Install-Module AzureADPreview -Force

#Download the .Net 4.8 offline - For windows Server 2016/2019
mkdir -p c:\temp\downloads\
Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2088631 -OutFile c:\temp\downloads\ndp48-x86-x64-allos-enu.exe
C:\temp\downloads\ndp48-x86-x64-allos-enu.exe

#Download Skype for business module
Invoke-WebRequest -Uri https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.exe -OutFile c:\temp\downloads\SkypeOnlinePowerShell.exe
C:\temp\downloads\SkypeOnlinePowerShell.exe

#Importing Modules
Import-Module MSOnline
Import-Module MicrosoftTeams
Import-Module SkypeOnlineConnector
Import-Module AzureADPreview

#Connect Modules (will open one Web Browser for each connection if MFA enabled on O365 tenant)
Connect-MicrosoftTeams
Connect-ExchangeOnline
Connect-AzureAD
Connect-MsolService

#Connect Skype for Business Online

$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession -AllowClobber
Enable-CsOnlineSessionForReconnection


#begin
clear
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host -ForegroundColor Magenta "Exporting Groups to CSV"
Start-Sleep 10
clear
$sourcefile = "C:\temp\sourcegroups.txt"
$targetfile = "C:\temp\o365_team_mgmt_group_members.txt"
del C:\temp\sourcegroups.txt
del C:\temp\o365_team_mgmt_group_members.txt
(Get-ADGroupMember -Identity E1-collab-lic).samaccountname | Out-File $sourcefile -Append
(Get-ADGroupMember -Identity E3-collab-lic).samaccountname | Out-File $sourcefile -Append
(Get-ADGroupMember -Identity O365_Teams_Mgmt).samaccountname | Out-File $targetfile -Append
$array = Get-Content -Path @("$sourcefile")
$o365mgmtgroup = Get-Content -Path @("$targetfile")

$group = "O365_Team_Mgmt"
$members = Get-Content .\sourcegroups.txt

write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host ""
write-host -ForegroundColor Magenta "Checking Groups Membership"
ForEach ($user in $o365mgmtgroup) {
write-host "working on user $user"
    If ($members -contains $user) {
      Write-Host -ForegroundColor Green "$user exists in the group $_"
 } Else {
      Write-Host -ForegroundColor Yellow "$user not exists in the group $_"
      write-host -ForegroundColor Cyan "Removing user $user from group"
      Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
}}
Start-Sleep 5