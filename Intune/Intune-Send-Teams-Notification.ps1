<#
.SYNOPSIS
This script sends a notification (HTML format table) to a specific Teams Channel

.DESCRIPTION
This script requires Teams Channel, a Connect (webhook) and a few variables self-explained in the code

.NOTES
Author: Thiago Beier
Email: thiago.beier@gmail.com
Blog: https://thebeier.com
LinkedIn: https://www.linkedin.com/in/tbeier/
Twitter: https://twitter.com/thiagobeier
Date: 03/10/2023
Version: 1.0
#>

# Functions
# Function to send notificaton to teams
#Date and time
$dt = Get-Date -Format "dd-MM-yyyy-HH-mm-ss"

#variable to test the html webhook

$session = New-CimSession
$serial = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber

$env:COMPUTERNAME
$tmpgrouptag = "EMPTY"
#$dt
#$serial
$groupTag = "CONTOSO"

function SendTeamsNotification {
    #sending end-user toast notification
    Write-Output 'sending end-user toast notification'

    $payload = @{
        "channel" = "#general"
        #"text" = "Alert!!! New Windows Autopilot Device Name: $env:COMPUTERNAME added to BULC: $grouptag "
        "text"    = "<style>h1 {text-align: center;}p {text-align: center;}div {text-align: center;}</style><h1><b>Alert</b></h1><br><table border=1><tr><th>Current Device Name</th><th>Current BULC code</th><th>Date & Time</th><th>SERIAL</th><th>New BULC code</th></tr><tr><td>$env:COMPUTERNAME</td><td>$($tmpgrouptag)</td><td>$dt</td><td>$serial</td><td>$groupTag</td></tr></table>"
    }

    #then we invoke web request using the uri which is the Teamswebhook url alongside the post method to send our request
    Invoke-WebRequest -UseBasicParsing `
        -Body (ConvertTo-Json -Compress -InputObject $payload) `
        -Method Post `
        -Uri "https://m365x58705501.webhook.office.com/webhookb2/xxxxxxx@yyyyyyyyy/IncomingWebhook/c88bf2bcfa8e498e9d67bfe192cf9a58/zzzzzzzzz"
    Write-Output "The condition was true"
}
# Function to upload imported / updated devices to SharePoint List

SendTeamsNotification
