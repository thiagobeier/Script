<#
.SYNOPSIS
This script syncs Outlook Template Files to users / detection (multiple files)
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

$url1 = "https://YOUR-STORAGE-URL/PROJECT  - TOPIC1.oft"
$url2 = "https://YOUR-STORAGE-URL/PROJECT  - TOPIC2.oft"
$url3 = "https://YOUR-STORAGE-URL/PROJECT  - TOPIC .oft"
#$url4 = "https://www.example.com/file3.txt"

# Add the URLs to an array
$urlArray = @($url1, $url2, $url3)


# Loop the URL array to grab the file name with extention
foreach ($url in $urlArray) {

# if one file is missing "Not Compliant" it will trigger the remediation
$lastPart = $url.Split("/")[-1]
$lastPart

$fileexists = Get-childitem -Path "C:\Users\$User\AppData\Roaming\Microsoft\Templates\$lastPart" -ErrorAction SilentlyContinue #| fl *
    if ($fileexists) {
    "Compliant"
    exit 0
    } 
    else {
    "Not Compliant"
    exit 1
    }

}