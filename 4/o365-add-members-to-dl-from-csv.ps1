###########################################################################################    
# Author Thiago Beier thiago.beier@gmail.com    
# Version: 1.0 - 2020-FEB-28   
# Adding user to a DL (Distribution List on Office 365) from CSV file
# Toronto,CANADA    
# Email: thiago.beier@gmail.com  
# https://www.linkedin.com/in/tbeier/  
# https://thigobeier.wordpress.com
########################################################################################### 

#
Import-Csv add-members-to-dl01.csv | foreach { 

write-host "Adding user" $_.members "to" $_.dlistname "DL" -ForegroundColor Yellow

Add-DistributionGroupMember -Identity $_.dlistname -Member $_.members 

}
