#detect drawio

try
{
$detecta = Get-AppxPackage | select * | where-object {$_ -like "*draw.io.draw.ioDiagrams*"}
if ($detecta) {
"removing $($detecta.Name)"
#Remove-AppxPackage -AllUsers -Package $detecta.PackageFullName
#echo "detected" | out-file detected.txt
exit 1
} else {
    "do nothing"
    #echo "not found" | out-file not-found.txt
    exit 0
    }
 }
catch{
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}