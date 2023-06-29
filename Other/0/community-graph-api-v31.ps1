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
    [Parameter(Mandatory = $False, ParameterSetName = 'Hybrid')] [String] $AppSecret = "",
    [Parameter(Mandatory = $False, ParameterSetName = 'Hybrid')] [String] $Tenantname = ""
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
Connect-MSGraphApp -TenantId $tenantID -AppId $app -AppSecret $secret -Tenantname $Tenantname
 
-#>
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $false)] [string]$TenantId,
        [Parameter(Mandatory = $false)] [string]$AppId,
        [Parameter(Mandatory = $false)] [string]$AppSecret,
        [Parameter(Mandatory = $false)] [string]$Tenantname
    )

    Process {
        Import-Module Microsoft.Graph.Authentication
            $retokenbody = @{
                Grant_type = "client_credentials"
                Scope = "https://graph.microsoft.com/.default"
                client_id = $AppId
                client_secret = $AppSecret
            }
            $tokenresponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$Tenantname/oauth2/v2.0/token" -Method Post -Body $retokenbody
            $tokenresponse

            # Connect All MSGraph & MGGraph
try
{
    Write-host "Connecting to MSGraph"
    Import-Module Microsoft.Graph.Intune
    Import-Module Microsoft.Graph.Users
    Import-Module Microsoft.Graph.DeviceManagement
    Import-Module Microsoft.Graph.Groups
    Import-Module Microsoft.Graph.Identity.DirectoryManagement
    Import-Module -Name MSAL.PS -Force
    Import-Module WindowsAutopilotIntune
    $authority = "https://login.windows.net/$Tenantname"
    Update-MSGraphEnvironment -AppId $AppId -Quiet
    Update-MSGraphEnvironment -AuthUrl $authority -Quiet
    Connect-MSGraph -ClientSecret $AppSecret -Quiet
    Connect-MgGraph -AccessToken $tokenresponse.access_token
}
catch
{
    Write-host "ERROR: Could not connect to MSGraph (for Intune) - exiting!" -ForegroundColor Red
    write-host $_.Exception.Message -ForegroundColor Red
    #exit;
}
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

function Setup-Modules (){
# Modules
$Modules = @(
    "Microsoft.Graph.Users"
	"Microsoft.Graph.Groups"
	"Microsoft.Graph.Intune"
	"Microsoft.Graph.DeviceManagement"
	"Microsoft.Graph.Authentication"
	"Microsoft.Graph.Identity.DirectoryManagement"
	"MSAL.PS"
	"WindowsAutoPilotIntune"
)

foreach ($Module in $Modules){
    if (Get-InstalledModule $Module){
        Write-Host "$Module Module Present" -ForegroundColor Green
    }else{
        Write-Host "Installing $Module Module" -ForegroundColor Yellow
        Install-Module $Module -Confirm:$false -Force:$true
    }
}
$Provider = "NuGet"
$ProviderVersion = "2.8.5.201"
if (Get-PackageProvider -Name $Provider){
	    Write-Host "$Provider Present" -ForegroundColor Green
    }else{
        Write-Host "Installing $Provider Module" -ForegroundColor Yellow
        Install-PackageProvider -Name $Provider -MinimumVersion $ProviderVersion -Confirm:$false -Force:$true
    }


}
#



    # If online, make sure we are able to authenticate
    if ($Hybrid) {

    Write-Host -ForegroundColor Green "### Worked ###"

    Test-ADDS

    Setup-Modules

    #Region : Connecting MSGraph MGGraph

<#
    try
    {
        Write-host "Connecting to MSGraph"
        Import-Module Microsoft.Graph.Intune
        Import-Module Microsoft.Graph.Users
        Import-Module Microsoft.Graph.DeviceManagement
        Import-Module Microsoft.Graph.Groups
        Import-Module Microsoft.Graph.Identity.DirectoryManagement
        Import-Module -Name MSAL.PS -Force
        Import-Module WindowsAutopilotIntune
        $authority = "https://login.windows.net/$Tenantname"
        #Update-MSGraphEnvironment -AppId $AppId -Quiet
        #Update-MSGraphEnvironment -AuthUrl $authority -Quiet
        Connect-MSGraph -ClientSecret $AppSecret -Quiet
        Connect-MgGraph -AccessToken $accessToken
    }
    catch
    {
        Write-host "ERROR: Could not connect to MSGraph (for Intune) - exiting!" -ForegroundColor Red
        write-host $_.Exception.Message -ForegroundColor Red
        #exit;
    }
#>
    
       # Connect
        if ($AppId -ne "") {
            $retokenbody = @{
                Grant_type = "client_credentials"
                Scope = "https://graph.microsoft.com/.default"
                client_id = $AppId
                client_secret = $AppSecret
            }
            $tokenresponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$Tenantname/oauth2/v2.0/token" -Method Post -Body $retokenbody
            $tokenresponse

            # Connect All MSGraph & MGGraph
try{        "Installing Packages"    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$false -Force:$true    #Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false    Install-Module -Name Microsoft.Graph.Users -Confirm:$false -Force:$true    Install-Module -Name Microsoft.Graph.Groups -Confirm:$false -Force:$true    Install-Module -Name Microsoft.Graph.Intune -Confirm:$false -Force:$true    Install-Module -Name Microsoft.Graph.DeviceManagement -Confirm:$false -Force:$true    Install-module -Name Microsoft.Graph.Authentication -Confirm:$false -Force:$true    Install-Module -Name Microsoft.Graph.Identity.DirectoryManagement -Confirm:$false -Force:$true    Install-Module -Name MSAL.PS -Force -Confirm:$false    Install-Module -Name WindowsAutoPilotIntune -Confirm:$false -Force:$true        Write-host "Connecting to MSGraph"    Import-Module Microsoft.Graph.Intune    Import-Module Microsoft.Graph.Users    Import-Module Microsoft.Graph.DeviceManagement    Import-Module Microsoft.Graph.Groups    Import-Module Microsoft.Graph.Identity.DirectoryManagement    Import-Module -Name MSAL.PS -Force    #Import-Module WindowsAutopilotIntune    #$tenant = "constellationhbs.onmicrosoft.com"    $authority = "https://login.windows.net/$tenantname"    Update-MSGraphEnvironment -AppId $AppId -Quiet    Update-MSGraphEnvironment -AuthUrl $authority -Quiet    Connect-MSGraph -ClientSecret $AppSecret -Quiet    Connect-MgGraph -AccessToken $tokenresponse.access_token}catch{    Write-host "ERROR: Could not connect to MSGraph (for Intune) - exiting!" -ForegroundColor Red    write-host $_.Exception.Message -ForegroundColor Red    #exit;}

            #Select-MgProfile -Name Beta
            #$graph = Connect-MgGraph -AccessToken $accessToken
            #Write-Host "Connected to Intune tenant $TenantId using app-based authentication (Azure AD authentication not supported)"
        }
        else {
            #$graph = Connect-MgGraph -scopes Group.ReadWrite.All, Device.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, GroupMember.ReadWrite.All
            #Write-Host "Connected to Intune tenant $($graph.TenantId)"
            #if ($AddToGroup) {
            #    $aadId = Connect-MgGraph -scopes Group.ReadWrite.All, Device.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, GroupMember.ReadWrite.All
            #    Write-Host "Connected to Azure AD tenant $($aadId.TenantId)"
            #}
        }

        # Load Lists
        #(Get-MgUser -All| Get-MSGraphAllPages | Measure-Object).count #All Users (all)
        #(Get-MgGroup -All| Get-MSGraphAllPages | Measure-Object).count #All Groups (all)
        #(Get-MgDevice -All| Get-MSGraphAllPages | Measure-Object).count #All AAD devices
        (Get-MgDeviceManagementManagedDevice -All).count #Intune Devices (all)
        (Get-AutopilotDevice| Measure-Object).count #All Windows autopilot devices (all) win/macos

    }


