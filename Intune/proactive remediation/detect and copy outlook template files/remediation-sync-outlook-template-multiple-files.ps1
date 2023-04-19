<#
.SYNOPSIS
This script syncs Outlook Template Files to users / remediation (multiple files)
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

$url1 = "https://YOUR-STORAGE-URL/PROJECT  - TOPIC1.oft"
$url2 = "https://YOUR-STORAGE-URL/PROJECT  - TOPIC2.oft"
$url3 = "https://YOUR-STORAGE-URL/PROJECT  - TOPIC .oft"
#$url4 = "https://www.example.com/file3.txt"

# Add the URLs to an array
$urlArray = @($url1, $url2, $url3) #if you add $url4 in URLS add it at the array as well => $urlArray = @($url1, $url2, $url3, $url4)

$User = $env:USERNAME

# Loop through the URLs and download the contents
foreach ($url in $urlArray) {
    $filename = (Split-Path -Leaf $url)
    $outputPath = "C:\Users\$User\AppData\Roaming\Microsoft\Templates\"
    "Copying File $filename"
    Invoke-WebRequest -Uri $url -OutFile $outputPath\$filename
}
