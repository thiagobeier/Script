###############################################################################################################################################################################################################################################
# Author Thiago Beier thiago.beier@gmail.com   
# Version: 1.0 - 2020-03-09  
# Assign ATP licenses to Users from TXT file
# Toronto, CANADA   
# Email: thiago.beier@gmail.com 
# https://www.linkedin.com/in/tbeier/ 
# https://twitter.com/thiagobeier
# thiagobeier.wordpress.com
###############################################################################################################################################################################################################################################  


$userlist = Get-Content .\users.txt
#where users.txt has users formated as UPN or email address as thiago@thebeier.com 
foreach ($user in $userlist) {
write-host "Assigning license to user:" $user -ForegroundColor Blue

#assign license
$userUPN = "$user"
$planName="ATP_ENTERPRISE"
$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $License
Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $LicensesToAssign

}