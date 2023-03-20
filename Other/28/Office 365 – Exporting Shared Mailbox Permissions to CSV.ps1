############################################################################################################################################################################################################################################### 
# Author Thiago Beier thiago.beier@gmail.com    
# Version: 1.0 - 2020-05-02   
#
# Export all shared mailboxes permissions from Office 365 based on domain name = ProxyAddress
#
#
# Toronto, CANADA    
# Email: thiago.beier@gmail.com  
# https://www.linkedin.com/in/tbeier/  
# https://twitter.com/thiagobeier 
# https://thiagobeier.wordpress.com 

###############################################################################################################################################################################################################################################   

Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited -Filter {(emailaddresses -like "*thebeier.com") -or (emailaddresses -like "*collabcan.com")} | Get-MailboxPermission | Select Identity, User, Deny, AccessRights, IsInherited| Where {($_.user -ne "NT AUTHORITY\SELF")}| Export-Csv -Path "THEBEIER-NonOwnerPermissions.csv" -NoTypeInformation