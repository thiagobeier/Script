############################################################################################################################################################################################################################################### 

# Author Thiago Beier thiago.beier@gmail.com    

# Version: 1.0 - 2020-04-17   

# Install Office 365, Skype for Business and Microsoft Teams Modules & connect to them.

# Downloads and installs pre-requisites for Windows 2016 & 2019 Server

# Downloads and installs pre-requisites for Windows 10

# Toronto, CANADA    

# Email: thiago.beier@gmail.com  

# https://www.linkedin.com/in/tbeier/  

# https://twitter.com/thiagobeier 

# thiagobeier.wordpress.com 

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