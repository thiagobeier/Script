
# Detect Device Name and create BUXX BULC
function Get-DsRegCmd {
	$DsRegCmd = $env:COMPUTERNAME
    return $Dsregcmd
}

$DSREG_Output = Get-DsRegCmd
#$DSREG_Output 


function Get-DeviceNameStatus {
    #$DSREG_Output 
    #clear
    $name = $DSREG_Output

    if ($name -like "DESKTOP*" -or $name -like "Auto*") { #{"y"} else {"n"}
        #"default"
        #buxx
        return "Not compliant"
         Write-Warning "Not Compliant"
        Exit 1
    } else {
        return "Compliant"
        Write-Output "Compliant"
        Exit 0
    }
}

Get-DeviceNameStatus