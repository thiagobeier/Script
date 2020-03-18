################################################################################ 
#Author Thiago Beier thiago.beier@gmail.com 
#Version: 1.0 
#Toronto,CANADA 
#Powershell Functions To Manager Office 365, Exchange Online, SharePoint and Skype for Business. 
#Before using this please check the PowerShell modules required 
################################################################################ 

#Redirects all powershell output to a file
Start-Transcript C:\temp\default-output-upn.txt

del C:\temp\users-upn-in-adds.txt
del C:\temp\upn-found-inadds.txt
del 

$users = Get-MSOLUser -All | select UserPrincipalName
foreach ($upn in $users) {
$upn = ($upn -split 'UserPrincipalname=')[1] -split '}'
$upn = ($upn -split '@')[0]
Write-Host User UPN $upn found in Active Directory .... -ForegroundColor Green

ForEach ($addslogin in $upn) {
try 
{
#change here to set an specific OU
#get-aduser -SearchBase "OU=SBSUsers,OU=Users,OU=MyBusiness,DC=yourdomain,DC=local" -SearchScope Subtree $addslogin -Properties * |select enabled,name,displayname,lastlogondate >> C:\temp\users-upn-in-adds.txt
get-aduser $addslogin -Properties * | select name,displayname,samaccountname,lastlogondate >> C:\temp\users-upn-in-adds.txt
$addslogin >> C:\temp\upn-found-inadds.txt

}
Catch {
        write-Host User UPN $addslogin was not found in Active Directory ... -ForegroundColor red 
        $addslogin >> C:\temp\upn-notfound-inadds.txt
                
        }
    }

}


Stop-Transcript 