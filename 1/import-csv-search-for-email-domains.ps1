###############################################################################################################################################################################################################################################
# Author Thiago Beier thiago.beier@gmail.com   
# Version: 1.0 - 2020-03-09  
# Read all upn, email address, proxysmtpaddress and primarysmtpaddress from a CSV file and breaks into current users with specified domain name and users with different upn who have email on specified domain
# Toronto, CANADA   
# Email: thiago.beier@gmail.com 
# https://www.linkedin.com/in/tbeier/ 
# https://twitter.com/thiagobeier
# thiagobeier.wordpress.com
###############################################################################################################################################################################################################################################  
#Redirects all powershell output to a file 

#define reprot folder
$reportfolder = "report1"

#start transcript
Start-Transcript -Path "C:\temp\$reportfolder\Log-$(get-date -format 'MM_dd_yyyy-HH-mm').txt"

#domain list file
$domainlist1 = Get-Content .\domainlist.txt

#loop
foreach ($domain in $domainlist1) {
write-host $domain -ForegroundColor Blue
#define variable for the search domain
$searchdomain = $domain
write-host "users with domain:" $searchdomain "in PrimarySmtpAddress" -ForegroundColor Yellow
$find1 = (import-csv .\test-fulllist.csv | Where-Object {$_.primarysmtpaddress -like "*@$searchdomain*"}).count
write-host $find1 -ForegroundColor Red
#export current users on specified domain
import-csv .\test-fulllist.csv | Where-Object {$_.primarysmtpaddress -like "*@$searchdomain*"} | select DisplayName,UserPrincipalName,PrimarySmtpAddress | Export-Csv -NoTypeInformation -Encoding UTF8 C:\Temp\$reportfolder\current-users-on-$searchdomain.csv

#list users at different domains with this domain on proxysmtpaddress
write-host "users with domain:" "$searchdomain" "in EmailAddress that are from other domains" -ForegroundColor cyan
$find2 = (import-csv .\test-fulllist.csv | Where-Object {$_.emailaddresses -like "*$searchdomain*" -and $_.UserPrincipalName -notlike "*$searchdomain*"} | select UserPrincipalName).count #| measure
#export users on specified domain with different upn
import-csv .\test-fulllist.csv | Where-Object {$_.emailaddresses -like "*$searchdomain*" -and $_.UserPrincipalName -notlike "*$searchdomain*"} | select DisplayName,UserPrincipalName,PrimarySmtpAddress | Export-Csv -NoTypeInformation -Encoding UTF8 C:\Temp\$reportfolder\$searchdomain.csv
write-host "found" $find2 "users with" $domain "as proxysmtpaddress" -ForegroundColor Green
}