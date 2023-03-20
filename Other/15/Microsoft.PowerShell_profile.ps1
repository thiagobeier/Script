#BEGIN
Function Connect-Office365Full {
    
    #exchange
    $URL = "https://ps.outlook.com/powershell"
    $Credentials = Get-Credential -Message "Enter your Office 365 admin credentials"
    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URL -Credential $Credentials -Authentication Basic -AllowRedirection -Name "ExchangeOnline"
    Import-PSSession $EXOSession

    #office365
    Import-Module MsOnline
    Connect-MsolService -Credential $Credentials

    #skype for business
    Import-Module LyncOnlineConnector
    $sfbSession = New-CsOnlineSession -Credential $Credentials
    Import-PSSession $sfbSession

    #azure AD
    Connect-AzureAD -Credential $Credentials -Confirm:$false

}


Function Connect-Tenant {
    
  
    
    #exchange tenant
    $domainname = Read-Host -Prompt "Enter your tenant domain"
    $tenantadminname = Read-Host -Prompt "Enter your tenant admin account name"
    $AdminName = "$tenantadminname@$domainname"
    Read-Host -Prompt "Enter your tenant password" -AsSecureString | ConvertFrom-SecureString | Out-File cred.txt
    $Pass = Get-Content cred.txt | ConvertTo-SecureString
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName, $Pass
    Import-Module MSOnline
    Connect-MsolService -Credential $cred
    
    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
    Import-PSSession $EXOSession -AllowClobber

    Connect-AzureAD -Credential $cred -Confirm:$false
}


function Get-O365GuestsUsersThroughAzureAD 
{    

    param($sCSVFileName)  
    Try 
    {    
        [array]$O365GuestsUsers = $null 
        $O365TenantGuestsUsers=Get-AzureADUser -Filter "Usertype eq 'Guest'” 
        foreach ($O365GuestUser in $O365TenantGuestsUsers)  
        {  
            $O365GuestsUsers=New-Object PSObject 
            $O365GuestsUsers | Add-Member NoteProperty -Name "Guest User DisplayName" -Value $O365GuestUser.DisplayName 
            $O365GuestsUsers | Add-Member NoteProperty -Name "User Principal Name" -Value $O365GuestUser.UserPrincipalName 
            $O365GuestsUsers | Add-Member NoteProperty -Name "Mail Address" -Value $O365GuestUser.Mail 
            $O365AllGuestsUsers+=$O365GuestsUsers   
        }  
        $O365AllGuestsUsers | Export-Csv $sCSVFileName 
    } 
    catch [System.Exception] 
    { 
        Write-Host -ForegroundColor Red $_.Exception.ToString()    
    }
            
} 


Function O365-Export-Guest-Users {

    $sCSVFileName="AllTenantGuestsUsers-$(get-date -f yyyy-MM-dd-HH-mm-ss).csv" 
    #Getting Tenant Guests Users 
    Get-O365GuestsUsersThroughAzureAD -sCSVFileName $sCSVFileName 

}

Function O365-Export-MFA-Disabled-Users {
$allmfadisabledusers = Get-MsolUser -All | where {$_.isLicensed -eq $true} | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} 
$allmfadisabledusers
$totalmfadisabledusers = ($allmfadisabledusers).count
write-host -ForegroundColor Yellow "You have $totalmfadisabledusers Users without MFA enabled"
}


Function O365-Export-MFA-Disabled-Users-OnScreen {
Get-MsolUser -All | where {$_.isLicensed -eq $true} | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | Out-GridView
}

Function Disconnect-Office365Full {
    
    Get-PSSession | Remove-PSSession 
    
}

Function Change-Office365Full {

    Disconnect-Office365Full
    Connect-Office365Full

}

Function Connect-SharepointOnline {

$adminUPN=read-host "<the full email address of a SharePoint Online global administrator account, example: jdoe@contosotoycompany.onmicrosoft.com>"
$orgName=read-host "<name of your Office 365 organization, example: contosotoycompany>"
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $Credentials
}
#END