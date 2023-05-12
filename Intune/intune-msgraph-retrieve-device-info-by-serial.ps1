<#
.SYNOPSIS
This script list current device info by serial number given (Windows or macOS)

.DESCRIPTION
This script list current device info by serial number given (Windows or macOS)
Edit line 23 if you want to add the SERIAL here, comment out line 21 if this option is selected

.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 05/09/2023
Version: 1.0
#>

Connect-MSGraph

$Serial = read-host “Please Enter the Serial Number”

#$Serial = "ADD-THE-SERIAL-HERE"

$MyDevice = Get-IntuneManagedDevice | Get-MSGraphAllPages | Where-Object {$_.SerialNumber -match $Serial}

$MyDevice