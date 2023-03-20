###############################################################################################################################################################################################################################################
# Author Thiago Beier thiago.beier@gmail.com   
# Version: 1.0 - 2020-03-09  
# List sum of total users, total enabled accounts, total disabled accounts in ADDS (you can restrict the search to a specific OU - line 12 and 13
# Toronto, CANADA   
# Email: thiago.beier@gmail.com 
# https://www.linkedin.com/in/tbeier/ 
# https://twitter.com/thiagobeier
# thiagobeier.wordpress.com
###############################################################################################################################################################################################################################################  

#Get-ADUser -Filter * -SearchBase "OU=Field,OU=Users,OU=Toronto,DC=canada,DC=local" |fl name | measure
$userstotal = Get-ADUser -Filter * -SearchBase "DC=canada,DC=local" |fl name | measure
$usersenabled = Get-ADUser -Filter {Enabled -eq $true} | fl name | measure
$usersdisabled = Get-ADUser -Filter {Enabled -eq $false} | fl name | measure
write-host -ForegroundColor Magenta "########################## ADDS - TGAM - Users Report ###########################"
Write-Host -ForegroundColor Yellow "Total Users" $userstotal.Count
Write-Host -ForegroundColor Green "Enabled Users" $usersenabled.Count
Write-Host -ForegroundColor Cyan "Disabled Users" $usersdisabled.Count
write-host -ForegroundColor Magenta "#################################################################################"