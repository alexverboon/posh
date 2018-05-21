

$ImageName = "Download Kali Linux 64 Bit"
$uri = "https://www.kali.org/downloads/"
$kali = Invoke-WebRequest -uri $uri
$IsoRef = $kali.links | select-object Title,href | where-object {$_.href -like "*iso*" -and $_.title -like "$ImageName"}
$fileName = Split-Path $isoref.href -Leaf
$contentinfo = Invoke-WebRequest -uri $IsoRef.href -Method Head

Invoke-WebRequest -Uri $IsoRef.href -OutFile "c:\temp\$fileName"

