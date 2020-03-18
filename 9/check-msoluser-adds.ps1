################################################################################ 
#Author Thiago Beier thiago.beier@gmail.com 
#Version: 2.0 
#Toronto,CANADA 
#Powershell Functions To Manager Office 365, Exchange Online, SharePoint and Skype for Business. 
#Before using this please check the PowerShell modules required 
################################################################################ 

#Redirects all powershell output to a file
Start-Transcript C:\temp\default-powershell-output.txt


#Delete used TXT files before next run
del C:\temp\all-adds-users-ou.txt
del C:\temp\displayname-found-inadds.txt
del C:\temp\displayname-notfound-inadds.txt

#Retrieve all MSOL users from Office365 tenant domain and filter by DisplayName
$users = Get-MSOLUser -All | select DisplayName

$upn = ($users -split 'DisplayName=')[1] -split '}'
$upn = ($upn -split '@')[0]

foreach ($upn in $users) {
$upn = ($upn -split 'DisplayName=')[1] -split '}'
$upn = ($upn -split '@')[0]

get-aduser -filter "Displayname -like '$upn'" -Properties * |  select displayname,samaccountname,emailaddress,userprincipalname >> C:\temp\all-adds-users-ou.txt #export this output to a single text file

  if (Get-ADUser -filter "Displayname -like '$upn'" -Properties * -ErrorAction SilentlyContinue) {
                Write-host "$upn found in AD" -ForegroundColor Green
                $upn >> C:\temp\displayname-found-inadds.txt
                }        
        else {Write-host "$upn not found in AD" -ForegroundColor red
        $upn >> C:\temp\displayname-notfound-inadds.txt}

       }


#Stop powershell file redirection
Stop-Transcript 
