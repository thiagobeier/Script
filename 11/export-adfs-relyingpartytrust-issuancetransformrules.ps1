###########################################################################################   
#Author Thiago Beier thiago.beier@gmail.com   
#Version: 1.0 - 2019-08-15  
#Export ADFS relying party trust
#Export each separately on c:\users\YOUR-USERNAME\Documents\adfs\ folder 
#OS Version and Build: Microsoft Windows Server 2016 Standard , 10.0.14393 N/A Build 14393
#Tested with SCCM Version: 1902 
#Toronto,CANADA   
#email: thiago.beier@gmail.com 
#https://www.linkedin.com/in/tbeier/ 
###########################################################################################

$exportpath = "$env:USERPROFILE\Documents\adfs"

#creates c:\users\YOUR-USERNAME\Documents\adfs\ folder if doesn't exist

If(!(test-path "$exportpath"))
{
    New-Item -ItemType Directory -Force -Path $exportpath

    #list all ADFS relying party trust and export its IssuanceTransformRules

    $listappsname = Get-AdfsRelyingPartyTrust | select name
    #$listappsname
    foreach ($appname in $listappsname) {
    $fullappname = $appname.Name
    write-host $appname.Name -ForegroundColor Green
    (Get-AdfsRelyingPartyTrust -Name "$fullappname").IssuanceTransformRules | Out-File "$exportpath\$fullappname.txt"
    }

} else { write-host -ForegroundColor Yellow "Directory Exists" }

#export ADFS Endpoints
Get-AdfsEndpoint | fl * > "$exportpath\AdfsEndpoint.txt"

#export ADFS Claims Description
Get-AdfsClaimDescription | fl * > "$exportpath\AdfsClaimDescription.txt"

#export ADFS Certificates
Get-AdfsCertificate | fl * > "$exportpath\AdfsCertificates.txt"

#export ADFS Authentication Provider
Get-AdfsAuthenticationProvider | fl * > "$exportpath\AdfsAuthenticationProvider.txt"

#export ADFS AttributeStore
Get-AdfsAttributeStore | fl * > "$exportpath\AdfsAttributeStore.txt"

#export ADFS Access Control Policy
Get-AdfsAccessControlPolicy | fl * > "$exportpath\AdfsAccessControlPolicy.txt"

#Show on Screen

$adfsversion = (Get-Item C:\Windows\ADFS\Microsoft.IdentityServer.ServiceHost.exe).VersionInfo.ProductVersion 
write-host ""
write-host "ADFS Version:" -ForegroundColor White 
$showver = write-host -ForegroundColor Cyan $adfsversion


