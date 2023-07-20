<#PSScriptInfo
.VERSION 0.0.1
.AUTHOR Thiago Beier
.COMPANYNAME 
.COPYRIGHT GPL
.TAGS ADDS AzureAD Intune WindowsAutopilotDevices
.LICENSEURI https://github.com/thiagobeier/Windows-Devices-Inventory/blob/main/LICENSE
.PROJECTURI https://github.com/thiagobeier/Windows-Devices-Inventory
.ICONURI 
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
v0.0.1 - Initial version
v0.0.2 - Auth parameters Graph ADK2
#>

<#
.SYNOPSIS
Retrieves Windows Device from OnLine Azure AD joined Windows Autopilot Deployment profile and checks its object status in Azure AD, Intune and Windows AutoPilot devices - Community Version
GPL LICENSE
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
.DESCRIPTION
This script uses Get-ADComputer from ActiveDirectory powershell modules and MSGraph to retrieve AzureAD, Intune and Windows AutoPilot devices using Azure AD registered application with secret key as parameters.
.PARAMETER OnLine
Default on this version to look for each Synced Device objects to Azure AD that could be on a broken state (in AzureAD not in Intune or in Intune but the Azure AD joined device object not the OnLine Azure AD joined one)
.PARAMETER -TenantId
Required "Directory (tenant) ID" from the Azure AD application created for this purpose from https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/
.PARAMETER -AppId
Required "Application (client) ID" from the Azure AD application created for this purpose from https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/
.PARAMETER -AppSecret
Required "Client Secret Value" from the Azure AD application created for this purpose from https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/
.PARAMETER -Tenantname
Required "Primary domain" from the Azure AD Overview.- https://entra.microsoft.com/#view/Microsoft_AAD_IAM/TenantOverview.ReactView
.EXAMPLE
.\Windows-Devices-Inventory.ps1 -OnLine -TenantId YOUR-TENANTID -AppId YOUR-AZURE-AD-APP-CLIENT-ID -AppSecret YOUR-AZURE-AD-APP-CLIENT-ID-SECRET -Tenantname CONTOSO.onmicrosoft.com
.NOTES
Version:        0.0.1
Author:         Thiago Beier
WWW:            https://thebeier.com
Creation Date:  07/07/2023
#>

[CmdletBinding(DefaultParameterSetName = 'Default')]
param(
	[Parameter(Mandatory = $True, ParameterSetName = 'OnLine')] [Switch] $OnLine = $false,
	[Parameter(Mandatory = $False, ParameterSetName = 'OnLine')] [String] $TenantId = "",
	[Parameter(Mandatory = $False, ParameterSetName = 'OnLine')] [String] $AppId = "",
	[Parameter(Mandatory = $False, ParameterSetName = 'OnLine')] [String] $AppSecret = "",
	[Parameter(Mandatory = $False, ParameterSetName = 'OnLine')] [String] $Tenantname = ""
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
Connect-MSGraphApp -TenantId $tenantID -AppId $AppId -AppSecret $secret -Tenantname $Tenantname
 
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

        # Populate with the App Registration details and Tenant ID
        #$ClientId          = "NOT-REQUIRED-FOR-THIS-SCRIPT"
        #$ClientSecret      = "NOT-REQUIRED-FOR-THIS-SCRIPT" 
        #$TenantId          = "NOT-REQUIRED-FOR-THIS-SCRIPT" 
        $GraphScopes       = "https://graph.microsoft.com/.default"
        #$Tenantname        = "ADD-YOUR-TENANT-HERE.onmicrosoft.com"


        $headers = @{
            "Content-Type" = "application/x-www-form-urlencoded"
        }

        $body = "grant_type=client_credentials&client_id=$AppId&client_secret=$AppSecret&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default"
        $authUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
        $response = Invoke-RestMethod $authUri -Method 'POST' -Headers $headers -Body $body
        $response | ConvertTo-Json
 
        $token = $response.access_token
		
		# Connect All MSGraph & MGGraph
		try {
			

        # Authenticate to the Microsoft Graph
        Connect-MgGraph -AccessToken $token

        $authority = "https://login.windows.net/$Tenantname"
        Update-MSGraphEnvironment -AppId $AppId -Quiet
        Update-MSGraphEnvironment -AuthUrl $authority -Quiet
        Connect-MSGraph -ClientSecret $AppSecret -Quiet

			
		}
		catch {
			Write-host "ERROR: Could not connect to MSGraph - exiting!" -ForegroundColor Red
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

#region : Functions

function Get-ADDSDevicesList {
	$strDomainController = (Get-ADDomainController -Discover -ForceDiscover -ErrorAction SilentlyContinue).HostName.Value
	Write-Host "$($(Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")): Domain Controller Selected ($strDomainController)"

	if ($strDomainController) {
		$global:AllADDScomputers = ""
		"Connected to Domain Controller"
		# List AD computers
		$strAllADcomputers = Get-ADComputer -Server $strDomainController -Filter 'operatingsystem -ne "*server*" -and enabled -eq "true"' -ErrorAction SilentlyContinue
		#$strAllADcomputers.count
		#$strAllADcomputersResultStatus = $true
		$global:AllADDScomputers = $strAllADcomputers
	}
 else {
		"Could not contact Domain Controller"
		#$strAllADcomputersResultStatus = $false
		break
	}


}

function Install-Modules () {
# The following command only required one time execution
if ( Get-ExecutionPolicy)
{
    Write-Host "RemoteSigned policy exists."
}
else
{
    Write-Host "RemoteSigned policy does not exist."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
}

if (Get-Module -ListAvailable -Name Microsoft.Graph) {
    Write-Host "Microsoft.Graph Module exists"
} 
else {
    Write-Host "Microsoft.Graph Module does not exist"
    Install-Module Microsoft.Graph -Scope AllUsers
}

}
#
#endregion


# If OnLine, make sure we are able to authenticate
if ($OnLine) {

	Clear-Host

	Write-Host -ForegroundColor Green "### Executing OnLine ###"

	Install-Modules

	#Region : Connecting MSGraph
	# Connect
	if ($AppId -ne "") {
 
		try {

			
			write-host "Connecting MSGraph" -ForegroundColor Green
			Connect-MSGraphApp -TenantId $TenantId -AppId $AppId -AppSecret $AppSecret -Tenantname $Tenantname
			
		}
		catch {
			Write-host "ERROR: Could not connect to MSGraph (for Intune) - exiting!" -ForegroundColor Red
			write-host $_.Exception.Message -ForegroundColor Red
			#exit;
		}

		#Select-MgProfile -Name Beta
		#$graph = Connect-MgGraph -AccessToken $accessToken
		#Write-Host "Connected to Intune tenant $TenantId using app-based authentication (Azure AD authentication not supported)"
	}
	else {
		#$graph = Connect-MgGraph -scopes Group.ReadWrite.All, Device.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, GroupMember.ReadWrite.All
		#Write-Host "Connected to Intune tenant $($graph.TenantId)"
		#if ($AddToGroup) {
		#$aadId = Connect-MgGraph -scopes Group.ReadWrite.All, Device.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, GroupMember.ReadWrite.All
		#Write-Host "Connected to Azure AD tenant $($aadId.TenantId)"
		#}
	}



#region : Code

# Clear all variables
#$global:AllAADUsersList = "" #Future Version (Registered Users Owned Devices)
$global:AllAADDevicesList = ""
#$global:AllAADGroupsList = "" #Future Version (Registered Users Owned Devices / Membership)
$global:AllIntuneDevicesList = ""
$global:AllWinAutopilotDevicesList = ""

# Load Lists
$global:AllAADUsersList = (Get-MgUser -All | Get-MSGraphAllPages).count #Future Version (Registered Users Owned Devices)
$global:AllAADDevicesList = (Get-MgDevice -All | Get-MSGraphAllPages).count
$global:AllAADGroupsList = (Get-MgGroup -All | Get-MSGraphAllPages).count #Future Version (Registered Users Owned Devices / Membership)
$global:AllIntuneDevicesList = (Get-MgDeviceManagementManagedDevice -All).count
$global:AllWinAutopilotDevicesList = (Get-AutopilotDevice).count

# Print Results
Write-Host "Azure AD Users: $($global:AllAADUsersList)" -ForegroundColor Yellow
Write-Host "Azure AD Devices: $($global:AllAADDevicesList)" -ForegroundColor Yellow
Write-Host "Azure AD Groups: $($global:AllAADGroupsList)" -ForegroundColor Yellow
Write-Host "Intune Devices: $($global:AllIntuneDevicesList)" -ForegroundColor Yellow
Write-Host "Autopilot Devices: $($global:AllWinAutopilotDevicesList)" -ForegroundColor Yellow
#endregion
	

}


<#
gcm Get-MgUser
gcm Get-MgGroup
gcm Get-MgDevice
gcm Get-MgDeviceManagementManagedDevice
gcm Get-AutopilotDevice
#>


