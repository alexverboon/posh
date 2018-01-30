
$apikey = "<PASTE KEY HERE>"
Set-MSRCApiKey -ApiKey $apikey


#https://sqljana.wordpress.com/2017/08/31/powershell-get-security-updates-list-from-microsoft-by-monthproductkbcve-with-api/


$id = Get-MsrcCvrfDocument -ID '2017-Dec'


$affsw = Get-MsrcCvrfAffectedSoftware -Vulnerability $id.Vulnerability -ProductTree $id.ProductTree
$affsw
$affsw | Where-Object {$_.fullproductname -match "1709"}

$cvesum = Get-MsrcCvrfCVESummary -Vulnerability $id.Vulnerability -ProductTree $id.ProductTree
$cvesum | Where-Object {$_."Affected Software" -match "1709"}

$explind = Get-MsrcCvrfExploitabilityIndex -Vulnerability $id.Vulnerability

Get-MsrcVulnerabilityReportHtml -Vulnerability $id.Vulnerability -ProductTree $id.ProductTree 
 Out-File -FilePath "C:\temp\$($id.documenttitle).html"
Invoke-Item -Path "C:\temp\$($id.documenttitle).html"
