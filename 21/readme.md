Hyperv-VMM-2012R2-UpdateKBList

This script will download all recomended hotfixes and updates for Windows Server
2012 and Windows Server 2012 R2 Hyper-V Network Virtualization (HNV)
environments.

To use this script, download it and run it as Administrator.

To run it on ISE replace the line "\$dir = Split-Path
\$MyInvocation.MyCommand.Path" by this "\$dir = Split-Path \$scriptpath"Remenber
to allow script execution on

Powershell by executing this "Set-ExecutionPolicy Unrestricted -Force"

To see built-in help, try:

**PowerShell**

\#  Copyright (C) 2015 by Thiago Beier (thiago.beier\@gmail.com) 

\#  All Rights Reserved. 

 

\#  Updates List for Hyper-v Windows Server 2012 R2 and VMM 2012 R2 

\#  It opens de Explorer.exe on the destination folder "Default is C:\\Download" change according to your environment. 

 

\$userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:7.0.1) Gecko/20100101 Firefox/7.0.1" 

\$web = **New-Object** System.Net.WebClient 

\$web.Headers.Add("user-agent", \$userAgent) 

\#if ISE run this and comment the line below \$dir = Split-Path \$scriptpath 

\$dir = **Split-Path** \$MyInvocation.MyCommand.Path 

Write-Output \$dir 

 

\# Create the destination folder if it doesn't exist 

\# Specify the path or change it below 

\$destDir = "C:\\Download" 

 

\# Check if the folder exist if not create it  

 **If** (!(**Test-Path** \$destDir)) { 

   **New-Item** -Path \$destDir -ItemType Directory 

} 

**else** { 

   Write-Host "\`n" 

   Write-Host "Directory already exists!" -ForegroundColor "red" 

   Write-Host "\`n" 

} 

 

\# Start the Download 

**Get-Content** \$dir\\urls.txt \| 

    **Foreach**-Object {  

        write-host -ForegroundColor "cyan" "Downloading  " + \$_  

        **try** { 

            \$target = **join-path** \$destDir ([io.path]::getfilename(\$_)) 

            \$web.DownloadFile(\$_, \$target) 

        } **catch** { 

            \$_.Exception.Message 

        } 

}  

 

\#Write the completed message 

Write-Host "\`n\`n\`n" 

Write-Host "Download Completed" -foregroundcolor "green" 

Write-Host "\`n\`n\`n" 

 

\#it Opens the destination folder using Explorer.exe 

**ii** \$destDir

 

urls.txt
