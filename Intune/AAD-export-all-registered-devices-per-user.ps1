<#
.SYNOPSIS
This script retrieve all user registered devices Azure AD (AAD) per user and export to local path.

.DESCRIPTION
This script retrieve all user registered devices Azure AD (AAD) per user.
Used to identify devices and work on a cleanup
Export file name format: all-registered-aad-devicesv-$dt.csv

.NOTES
Fixed the 100-device return limitation '-All'
Original post https://morgantechspace.com/2019/06/get-azure-ad-users-with-registered-devices-powershell.html

.AUTHOR
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 04/05/2023
Version: 1.0
#>

#Date and time
$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"

#

$Result=@()
$Users = Get-AzureADUser -All $true | Select UserPrincipalName,ObjectId
$Users | ForEach-Object {
$user = $_
Get-AzureADUserRegisteredDevice -All $true -ObjectId $user.ObjectId | ForEach-Object {
$Result += New-Object PSObject -property @{ 
DeviceOwner = $user.UserPrincipalName
DeviceName = $_.DisplayName
DeviceOSType = $_.DeviceOSType
ApproximateLastLogonTimeStamp = $_.ApproximateLastLogonTimeStamp
}
}
}

#Export
$Export = $Result | Select DeviceOwner,DeviceName,DeviceOSType,ApproximateLastLogonTimeStamp 
$Export | export-csv all-registered-aad-devicesv-$dt.csv -NoTypeInformation -Encoding utf8 -Append
