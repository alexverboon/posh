#Specify variables

$random = Get-Random -Minimum 1000 -Maximum 10000 

$User = "alex@asiaperf.onmicrosoft.com"
$SiteURL = "https://asiaperf.sharepoint.com"
$URLPath = "/Shared Documents/1Excel40M.xlsx"
$Target = "c:\temp\perf\2Excel40M$random.xlsx"

#$URLPath.Split("/")[-1]

#Add references to SharePoint client assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString

Try {
#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
$Context.Credentials = $Creds
}
Catch {
Write-Host "Unable to open Site Collection" $SiteURL -ForegroundColor Red
}

$TimeTaken = Measure-Command {
Try {
#Download File
Write-Host "Downloading" $URLPath "..." -ForegroundColor Yellow
$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Context,$URLPath)
[System.IO.FileStream] $WriteStream = [System.IO.File]::Open($Target,[System.IO.FileMode]::Create);
$FileInfo.Stream.CopyTo($WriteStream);

$WriteStream.Close()
}
Catch {
Write-Host "Unable to download file" $SiteURL -ForegroundColor Red
}
}

$TotalSeconds = [INT]$TimeTaken.TotalSeconds
Write-Host "-Download took" $TotalSeconds "Seconds" -ForegroundColor Green
