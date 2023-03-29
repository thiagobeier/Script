<#
.SYNOPSIS
This script uploads in this scenario autopilot enrollment status to SharePoint List (keeps history: device name, date & time, location code (OrderID / GroupTag) 

.DESCRIPTION
This is customized for Intune Import Hash to Windows Autopilot Devices
This script uploads in this scenario autopilot enrollment status to SharePoint List (keeps history: device name, date & time, location code (OrderID / GroupTag) 

.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 03/24/2023
Version: 1.0
#>

# Functions

function UploadSPTList {
    #TLS
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Install powershell module
    if (-not (Get-Module PnP.PowerShell -ListAvailable)) {
        Install-Module -Name "PnP.PowerShell" -Force -Confirm:$false
    }
    
    #Urls
    $siteUrl = "https://UPDATE-TO-YOUR-TENANTNAME.sharepoint.com/sites/Contoso" #please update to your TENANT NAME
    $site = Connect-PnPOnline -ClientId $AppId -Url $siteUrl -Tenant $($aadtenantname.onmicrosoft.com) -CertificatePath '.\PnPPowerShell.pfx' #Requires Azure AD Application using self-signed certificate

    # Get Context
    $dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"
    $clientContext = Get-PnPContext
    $targetWeb = Get-PnPWeb

    # Get the list object
    $targetList = $targetWeb.Lists.GetByTitle("Autopilot")
    $clientContext.Load($targetList)
    $clientContext.ExecuteQuery()
 
    # Get the fields object. List all the columns separated with comma
    $fields = "Id", "Title", "LocationCode", "Serial", "DateTime", "NewLocationCode"
    $ListItems = Get-PnPListItem -List $targetList -Fields $fields
    foreach ($ListItem in $ListItems) {  
        Write-Host "Item Id : " $ListItem["ID"]    "Item Title : " $ListItem["Title"]    "Item LocationCode : " $ListItem["LocationCode"]    "Item Serial : " $ListItem["Serial"]    "Item DateTime : " $ListItem["DateTime"]     "Item NewLocationCode : " $ListItem["NewLocationCode"]
    }

    #uncomment block below to validate variables
	#$env:COMPUTERNAME
    #$($grouptag)
    #$dt
    #$serial
    #$grouptag

    #upload values to SPT online list // List name: Autopilot (case sensitive)
    Add-PnPListItem -List "Autopilot" -Values @{
        "Title"       = $env:COMPUTERNAME ; 
        "LocationCode"    = $($temp.groupTag);
        "DateTime"    = $dt; 
        "Serial"      = $serial; 
        "NewLocationCode" = $grouptag; 
    }

}

# Generate Access Token to use in the connection string to MSGraph
$AppId = 'YOUR-AZURE-AD-APP-ID'
$TenantId = 'YOUR-TENANT-ID'
$AppSecret = 'YOUR-AZURE-AD-APP-ID-SECRET'
$GroupTag = "" #Location code for any company or BLANK for Hybrid Azure AD Default
$aadtenantname = 'YOUR-TENANT-NAME'


# Powershell Modules
"Installing Packages"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$false -Force:$true
Install-Script get-windowsautopilotinfo -Confirm:$false -Force:$true
Install-Module -Name Microsoft.Graph.Intune -Confirm:$false -Force:$true
Install-Module -Name WindowsAutoPilotIntune -Confirm:$false -Force:$true

# Your Code here
# Start-Transcript 

# Where $($temp.groupTag) variable is part of Intune Autopilot enrollment / import hash script as part of this post https://thiagobeier.wordpress.com/2023/03/21/enroll-windows-device-using-ppkg/

# Stop-Transcript

#Update SharePoint List
UploadSPTList