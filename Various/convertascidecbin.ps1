
## Convert ASCI to Decimal and Binary

$KeyAsci = "J"
$enc = [System.Text.Encoding]::ASCII
$Decimal = $enc.GetBytes("$keyAsci")
Write-host "Key Decimal: $Decimal" 
$result =[convert]::ToString("$Decimal",2)
write-host "Key Binary: $result"


$random = "1100010"
write-host "Random: $random"








