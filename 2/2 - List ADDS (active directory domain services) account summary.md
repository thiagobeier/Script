List ADDS (active directory domain services) account summary.

Hi there

Sometimes we got simply calls to list the following data from ADDS - Active
Directory Domain Users:

Total Users in ADDS forest / domain

Total Disabled Users in ADDS forest / domain

Total Enabled Users in ADDS forest / domain

In general you can use PowerShell remote to do so or you can connect direct
using RDP (remote desktop services) into a specific DC (Domain Controller) to
pull out this data request.

If your environment has [JEA - Just Enough
Administration ](https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/jea/overview?view=powershell-7)be
aware of limitations on powershell commands against specified Servers' roles and
features.

 

 

**PowerShell**

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# 

\# Author Thiago Beier thiago.beier\@gmail.com    

\# Version: 1.0 - 2020-03-09   

\# List sum of total users, total enabled accounts, total disabled accounts in ADDS (you can restrict the search to a specific OU - line 12 and 13 

\# Toronto, CANADA    

\# Email: thiago.beier\@gmail.com  

\# https://www.linkedin.com/in/tbeier/  

\# https://twitter.com/thiagobeier 

\# thiagobeier.wordpress.com 

\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#   

 

\#Get-ADUser -Filter \* -SearchBase "OU=Field,OU=Users,OU=Toronto,DC=canada,DC=local" \|fl name \| measure 

\$userstotal = Get-ADUser -**Filter** \* -SearchBase "DC=canada,DC=local" \|**fl** name \| measure 

\$usersenabled = Get-ADUser -**Filter** {Enabled -eq \$true} \| **fl** name \| measure 

\$usersdisabled = Get-ADUser -**Filter** {Enabled -eq \$false} \| **fl** name \| measure 

write-host -ForegroundColor Magenta "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# ADDS - TGAM - Users Report \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#" 

Write-Host -ForegroundColor Yellow "Total Users" \$userstotal.Count 

Write-Host -ForegroundColor Green "Enabled Users" \$usersenabled.Count 

Write-Host -ForegroundColor Cyan "Disabled Users" \$usersdisabled.Count 

write-host -ForegroundColor Magenta "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#"

 
