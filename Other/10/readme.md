Monitor a folder size on real-time every hour.

This script monitor a folder in real-time and displays its growth every one hour
(default).

You can customize the folder, the interval and also add the Send-Mailmessage
function https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/send-mailmessage?view=

This is a handy script to be used when you're transfering or syncing a large
amount of data between servers and you need to know how the growth is going.

We had a specific customer where we defined a narrow bandwidth
consumption  during the day and full during after hours.

Tip:

copy during the day up to 5 MBPS

roobcopy "E:\\DFS\\source" "\\\\downstream-srv01\\e\$\\DFS\\target" /IPG:146 /E
/B /COPYALL /R:6 /W:5 /XD DfsrPrivate /TEE /LOG+:e:\\preseed-folder01.log 

copy after hours unlimited with /MT (multi thread parameter)

roobcopy "E:\\DFS\\source" "\\\\downstream-srv01\\e\$\\DFS\\target" /E /B
/COPYALL /MT /R:6 /W:5 /XD DfsrPrivate /TEE /LOG+:e:\\preseed-folder01.log 

[robocopy](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy) documentation

 

**PowerShell**

\#Powershell 

\#Monitor Folder Growth  

\#Displays result in MB and in GB 

\#Author: Thiago Beier Toronto, ON Canada 

\#E-mail: thiago.beier\@gmail.com 

\#May-2018 

\#DFS , FileServer, Folder Size 

 

**do**{ 

\$result = "{0:N2} MB" -f ((**Get-ChildItem** \$folder -Recurse \| **Measure-Object** -Property Length -Sum -ErrorAction Stop).Sum / 1MB) 

\$result1 = "{0:N2} GB" -f ((**Get-ChildItem** \$folder -Recurse \| **Measure-Object** -Property Length -Sum -ErrorAction Stop).Sum / 1GB) 

 

\$hour = (**Get-Date**).ToString() 

 

write-host \$hour -ForegroundColor Yellow 

write-host \$result -ForegroundColor Green 

write-host \$result1 -ForegroundColor Cyan 

 

    **start-sleep** -Seconds 3600 \#validate status every 1 hour     

    \#start-sleep -Seconds 5 \#test every 15 seconds 

}**until**(\$infinity) 

 

 

 

Output:

 

 

**PowerShell**

7/14/2018 12:23:53 AM  

1,872.01 MB  

1.83 GB  

7/14/2018 12:33:53 AM  

1,872.01 MB  

1.83 GB 

 

 
