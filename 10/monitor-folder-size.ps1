#Powershell
#Monitor Folder Growth 
#Displays result in MB and in GB
#Author: Thiago Beier Toronto, ON Canada
#E-mail: thiago.beier@gmail.com
#May-2018
#DFS , FileServer, Folder Size

do{
$result = "{0:N2} MB" -f ((Get-ChildItem $folder -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
$result1 = "{0:N2} GB" -f ((Get-ChildItem $folder -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1GB)

$hour = (Get-Date).ToString()

write-host $hour -ForegroundColor Yellow
write-host $result -ForegroundColor Green
write-host $result1 -ForegroundColor Cyan

    start-sleep -Seconds 3600 #validate status every 1 hour    
    #start-sleep -Seconds 5 #test every 15 seconds
}until($infinity)
