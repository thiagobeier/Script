<#PSScriptInfo
.VERSION 1.0.0
.GUID xxxxxxx
.AUTHOR Thiago Beier
.COMPANYNAME 
.COPYRIGHT GPL
.TAGS intune endpoint MEM autopilot
.LICENSEURI 
.PROJECTURI 
.ICONURI 
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
v1.0.0 - Initial version
#>


[CmdletBinding(DefaultParameterSetName = 'Default')]
param(
    [Parameter(Mandatory = $True, ParameterSetName = 'Hybrid')] [Switch] $Hybrid = $false,
    [Parameter(Mandatory = $False, ParameterSetName = 'Hybrid')] [String] $TenantId = "",
    [Parameter(Mandatory = $False, ParameterSetName = 'Hybrid')] [String] $AppId = "",
    [Parameter(Mandatory = $False, ParameterSetName = 'Hybrid')] [String] $AppSecret = ""
)


#region App-based authentication
Function Connect-MSGraphApp {
    <#
.SYNOPSIS
Authenticates to the Graph API via the Microsoft.Graph.Intune module using app-based authentication.
 
.DESCRIPTION
The Connect-MSGraphApp cmdlet is a wrapper cmdlet that helps authenticate to the Intune Graph API using the Microsoft.Graph.Intune module. It leverages an Azure AD app ID and app secret for authentication. See https://oofhours.com/2019/11/29/app-based-authentication-with-intune/ for more information.
 
.PARAMETER Tenant
Specifies the tenant (e.g. contoso.onmicrosoft.com) to which to authenticate.
 
.PARAMETER AppId
Specifies the Azure AD app ID (GUID) for the application that will be used to authenticate.
 
.PARAMETER AppSecret
Specifies the Azure AD app secret corresponding to the app ID that will be used to authenticate.
 
.EXAMPLE
Connect-MSGraphApp -TenantId $tenantID -AppId $app -AppSecret $secret
 
-#>
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $false)] [string]$TenantId,
        [Parameter(Mandatory = $false)] [string]$AppId,
        [Parameter(Mandatory = $false)] [string]$AppSecret
    )

    Process {
        Import-Module Microsoft.Graph.Authentication
        $body = @{
            grant_type    = "client_credentials";
            client_id     = $AppId;
            client_secret = $AppSecret;
            scope         = "https://graph.microsoft.com/.default";
        }
 
        $response = Invoke-RestMethod -Method Post -Uri https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token -Body $body
        $accessToken = $response.access_token
 
        $accessToken

        Select-MgProfile -Name Beta
        Connect-MgGraph  -AccessToken $accessToken
    }
}

#region Helper methods

Function BoolToString() {
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $True)] [bool] $value
    )

    Process {
        return $value.ToString().ToLower()
    }
}

#endregion

function Test-ADDS {
$strDomainController = (Get-ADDomainController -Discover -ForceDiscover -ErrorAction SilentlyContinue).HostName.Value
Write-Host "$($(Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")): Domain Controller Selected ($strDomainController)"

if ($strDomainController) {
"T"
# List AD computers
$strAllADcomputers = Get-ADComputer -Server $strDomainController -Filter 'operatingsystem -ne "*server*" -and enabled -eq "true"' -ErrorAction SilentlyContinue
$strAllADcomputers.count
$strAllADcomputersResultStatus = $true
$strAllADcomputers.count

} else {
"F"
$strAllADcomputersResultStatus = $false
}


}



    # If online, make sure we are able to authenticate
    if ($Hybrid) {

    Write-Host -ForegroundColor Green "### Worked ###"

    Test-ADDS
    
       # Connect
        if ($AppId -ne "") {
            $body = @{
                grant_type    = "client_credentials";
                client_id     = $AppId;
                client_secret = $AppSecret;
                scope         = "https://graph.microsoft.com/.default";
            }
     
            $response = Invoke-RestMethod -Method Post -Uri https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token -Body $body
            $accessToken = $response.access_token
     
            $accessToken

            Select-MgProfile -Name Beta
            $graph = Connect-MgGraph  -AccessToken $accessToken 
            Write-Host "Connected to Intune tenant $TenantId using app-based authentication (Azure AD authentication not supported)"
        }
        else {
            $graph = Connect-MgGraph -scopes Group.ReadWrite.All, Device.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, GroupMember.ReadWrite.All
            Write-Host "Connected to Intune tenant $($graph.TenantId)"
            if ($AddToGroup) {
                $aadId = Connect-MgGraph -scopes Group.ReadWrite.All, Device.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, GroupMember.ReadWrite.All
                Write-Host "Connected to Azure AD tenant $($aadId.TenantId)"
            }
        }

        # Load Lists
        (Get-MgUser -All| Get-MSGraphAllPages | Measure-Object).count #All Users (all)
        (Get-MgGroup -All| Get-MSGraphAllPages | Measure-Object).count #All Groups (all)
        (Get-MgDevice -All| Get-MSGraphAllPages | Measure-Object).count #All AAD devices
        (Get-MgDeviceManagementManagedDevice -All).count #Intune Devices (all)
        (Get-AutopilotDevice| Measure-Object).count #All Windows autopilot devices (all) win/macos

    }


