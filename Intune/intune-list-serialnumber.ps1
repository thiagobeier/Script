#
.SYNOPSIS
This script list current device serial number (to be imported to windows autopilot in Intune)
.DESCRIPTION
This script list current device serial number (to be imported to windows autopilot in Intune)
.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 03/28/2023
Version: 1.0
#>

clear
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
$session = New-CimSession
$serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber
$serial
$serial | clip