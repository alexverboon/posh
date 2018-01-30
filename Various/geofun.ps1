
$target = "www.verboon.info"

Function Get-GeoIP {
param (
    [string]$IP 
)
    ([xml](Invoke-WebRequest "http://freegeoip.net/xml/$IP").Content).Response
}


$trcroutedata = Test-NetConnection -ComputerName $target -TraceRoute -InformationLevel Detailed

$details = @()
ForEach ($ip in $trcroutedata.TraceRoute)
{
    Write-host "Retrieving details for $ip"
    $geoip = Get-GeoIP -IP "$ip"

    $object = @{
    IP = $geoip.IP
    CountryCode = $geoip.CountryCode
    CountryName = $geoip.CountryName
    RegionCode = $geoip.RegionCode
    RegionName = $geoip.RegionName
    City = $geoip.City
    ZipCode = $geoip.ZipCode
    TimeZone = $geoip.TimeZone
    }
    $details += (New-Object -TypeName PSObject -Property $object)
}




