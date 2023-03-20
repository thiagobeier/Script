###########################################################################################    
# Author Thiago Beier thiago.beier@gmail.com    
# Version: 1.0 - 2020-FEB-28   
# Create a DL (Distribution List on Office 365) from CSV file
# Toronto,CANADA    
# Email: thiago.beier@gmail.com  
# https://www.linkedin.com/in/tbeier/  
# https://thigobeier.wordpress.com
########################################################################################### 

Import-Csv .\create-dl.csv | foreach {

write-host "Creating DL:" $_.dlname -ForegroundColor Blue
write-host $_.dlname -ForegroundColor green
New-DistributionGroup -Name $_.dlname -Alias $_.alias -Type security

write-host $_.alias -ForegroundColor Yellow
Set-DistributionGroup $_.dlname -HiddenFromAddressListsEnabled $True


}