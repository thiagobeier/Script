#remove drawio

try
{
$detecta = Get-AppxPackage | select * | where-object {$_ -like "*draw.io.draw.ioDiagrams*"}
if ($detecta) {
"removing $($detecta.Name)"
 Remove-AppxPackage -AllUsers -Package $detecta.PackageFullName
 echo "removed" | out-file removed.txt
exit 0
} else {
    "do nothing"
    exit 0
    }
 }
catch{
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}