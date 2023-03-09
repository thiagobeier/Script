<#
.SYNOPSIS
This script retrieve all devices from Intune that have Azure AD Device Id as null / 00000000-0000-0000-0000-000000000000

.DESCRIPTION
This script checks for stale devices in Intune

.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 03/09/2023
Version: 1.0

#>

Connect-MSGraph                                                                                                                                                                                            
$Devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem, 'Windows')" | Get-MSGraphAllPages                                                                                                    
$Devices                                                                                                                                                                                                   
$Devices | Where-Object {$_azureADDeviceId -eq "00000000-0000-0000-0000-000000000000"}                                                                                                                     
$Devices | Where-Object {$_.azureADDeviceId -eq "00000000-0000-0000-0000-000000000000"} | select-obejct deviceName,serialnumber,userprincipalname                                                                 
($Devices | Where-Object {$_.azureADDeviceId -eq "00000000-0000-0000-0000-000000000000"} | select-obejct deviceName,serialnumber,userprincipalname).count                                                         
$Devices | Where-Object {$_.azureADDeviceId -eq "00000000-0000-0000-0000-000000000000"} | select-obejct deviceName,serialnumber,userprincipalname | Out-GridView                                                  
$Devices | Where-Object {$_.azureADDeviceId -eq "00000000-0000-0000-0000-000000000000"} | select-obejct deviceName,serialnumber,userprincipalname | Out-GridHtml  