<#
.SYNOPSIS
This script syncs Outlook Template File to users / detection (single file)
.DESCRIPTION
This script requires Intune Proactive Remediation Task
.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 04/19/2023
Version: 1.0
#>

Clear-Host

# C:\Users\username\AppData\Roaming\Microsoft\Templates 
# Detection 

$Users = $env:USERNAME
$oftFileName = "PROJECT  - TOPIC .oft" #update here the file name, same file name on %appdata% , azure blob storage url path 

ForEach($User in $Users) {
    
    $fileexists = Get-childitem -Path "C:\Users\$User\AppData\Roaming\Microsoft\Templates\$oftFileName" -ErrorAction SilentlyContinue #| fl *
    if ($fileexists) {
    "Compliant"
    exit 0
    } 
    else {
    "Not Compliant"
    exit 1
    }

    }
