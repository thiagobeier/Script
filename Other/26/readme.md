This Script searches for a user on each Team and remove it from there

**Does not work** with you switched your Membership ty into Dynamic at the
Office Group (default is assigned)

Run the connect to Office 365 (without MFA) with a credentials stored in TXT
file

\$AdminName = "thiago.beier\@thebeier.com"

\$orgName="tecbis"

\$fileToCheck = "C:\\LVS\\thebeier.txt"

if (Test-Path \$fileToCheck -PathType leaf) {

Get-Content \$fileToCheck

\#all the commands in a single block when using the Azure Active Directory
PowerShell for Graph module. Specify the name of your domain host, and then run
them all at one time & when using the Microsoft Azure Active Directory Module
for Windows PowerShell module

\$Pass = Get-Content "c:\\LVS\\thebeier.txt" \| ConvertTo-SecureString

\$credential = new-object -typename System.Management.Automation.PSCredential
-argumentlist \$AdminName, \$Pass

\#\$credential = Get-Credential

Connect-AzureAD -Credential \$credential

Connect-MsolService -Credential \$credential

\#Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

\#Connect-SPOService -Url https://\$orgName-admin.sharepoint.com -credential
\$credential

Import-Module SkypeOnlineConnector

\$sfboSession = New-CsOnlineSession -Credential \$credential

Import-PSSession \$sfboSession -AllowClobber

\$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange
-ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/
-Credential \$credential -Authentication "Basic" -AllowRedirection

Import-PSSession \$SccSession -Prefix cc

Connect-ExchangeOnline -Credential \$credential -ShowProgress \$true

Import-Module MicrosoftTeams

Connect-MicrosoftTeams -Credential \$credential

\#get-msoluser -all

}

Else {

Write-Host "No file at this location"

Read-Host -Prompt "Enter your tenant password" -AsSecureString \|
ConvertFrom-SecureString \| Out-File "c:\\LVS\\thebeier.txt"

\$Pass = Get-Content "c:\\LVS\\thebeier.txt" \| ConvertTo-SecureString

\$credential = new-object -typename System.Management.Automation.PSCredential
-argumentlist \$AdminName, \$Pass

\#\$credential = Get-Credential

Connect-AzureAD -Credential \$credential

Connect-MsolService -Credential \$credential

\#Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

\#Connect-SPOService -Url https://\$orgName-admin.sharepoint.com -credential
\$credential

Import-Module SkypeOnlineConnector

\$sfboSession = New-CsOnlineSession -Credential \$credential

Import-PSSession \$sfboSession

\$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange
-ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/
-Credential \$credential -Authentication "Basic" -AllowRedirection

Import-PSSession \$SccSession -Prefix cc

Connect-ExchangeOnline -Credential \$credential -ShowProgress \$true

Import-Module MicrosoftTeams

Connect-MicrosoftTeams -Credential \$credential

}

Run the following script

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#

\# Author Thiago Beier thiago.beier\@gmail.com

\# Version: 1.0 - 2020-04-22

\#

\# Search for a user on each Team at Microsoft Teams and remove it from there.

\#

\# Does not work with you switched your Membership ty into Dynamic at the Office
Group (default is assigned)

\#

\# Toronto, CANADA

\# Email: thiago.beier\@gmail.com

\# https://www.linkedin.com/in/tbeier/

\# https://twitter.com/thiagobeier

\# thiagobeier.wordpress.com

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#

\#search for a user on each Team and remove it from there

clear

Start-Sleep 3

Start-Transcript -path
"Team-Mgmt-Logfile_\$((Get-Date).ToString('MM-dd-yyyy-hh-mm-ss')).txt"
-NoClobber -IncludeInvocationHeader

\$searchuser ="tcat\@collabcan.com"

foreach (\$team in Get-Team) {

\#\$team.DisplayName

write-host -ForegroundColor Green "Group:" \$team.DisplayName

write-host -ForegroundColor Green "Groupid:" \$team.GroupId

foreach (\$user in get-teamuser -GroupId \$team.GroupId) {

write-host -ForegroundColor Cyan "User:" \$user.name

\#Get-MsolUser -ObjectId \$user.UserId

\$email = (Get-MsolUser -ObjectId \$user.UserId).userprincipalname

\$email

[bool]\$email

if (!\$email) {write-host \$email -ForegroundColor yellow "string is null or
empty" }

else {

write-host -ForegroundColor red \$email "has value"

if (\$email -eq \$searchuser) {

write-host \$email -ForegroundColor yellow "USER found! at" \$team.DisplayName
"Team"

write-host \$email -ForegroundColor Magenta "removing USER from this Team"

Remove-TeamUser -GroupId \$team.GroupId -User \$email

}

}

}

}

Stop-Transcript

\#end this

**Feedback**

Please use the Issues tab to provide feedback. I will periodically create new
files to incorporate the changes and work if you as you'd like to.

I hope using this GitHub repository brings a sense of collaboration to the labs
and improves the overall quality of your skills development experience.

Regards,

**Thiago
Beier** [https://thiagobeier.wordpress.com](https://thiagobeier.wordpress.com/)

**Copyright © 2020 Thiago Beier Blog**
