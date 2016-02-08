

#Connect-SPOService -Url https://asiaperf-admin.sharepoint.com -credential $Cred

Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

 $SPOUser = "alex@asiaperf.onmicrosoft.com"
# Uses a hardcoded password, use only during test/lab:
$SPOPassword = convertto-securestring "Caba1199" -asplaintext -force
# Better: $SPOPassword = Read-Host -Prompt "Please enter your password" -AsSecureString
$SPOODfBUrl = "https://asiaperf.sharepoint.com"
$SiteURL = "https://asiaperf.sharepoint.com"

$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SPOODfBUrl)
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($SPOUser,$SPOPassword)
$Context.RequestTimeout = 16384000
$Context.Credentials = $Credentials
$Context.ExecuteQuery()

$Web = $Context.Web
$Context.Load($Web)
$Context.ExecuteQuery()


$SPODocLibName = "Documents"
$SPOList = $Web.Lists.GetByTitle($SPODocLibName)
$Context.Load($SPOList.RootFolder)
$Context.ExecuteQuery() 






<#
$FolderName = "Test1" 
$SPOFolder = $SPOList.RootFolder
$NewFolder = $SPOFolder.Folders.Add($FolderName)
$Web.Context.Load($NewFolder)
$Web.Context.ExecuteQuery()
#>

#Update-FormatData -AppendPath "C:\Data\dev\posh\Office365\SPClient.Format.ps1xml"



