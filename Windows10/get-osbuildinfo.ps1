function Get-WinBuildInfo
{
<#
.Synopsis
   Get-WinBuildInfo
.DESCRIPTION
   Get-WinBuildInfo retrieves Windows 10 version, build and Insider information
.EXAMPLE
   Get-WinBuildInfo
.NOTES
    https://buildfeed.net/
    https://technet.microsoft.com/en-us/windows/release-info.aspx
    https://support.microsoft.com/en-us/help/12387/windows-10-update-history?ocid=client_wu
#>

    [CmdletBinding()]
    Param
    (
    )

Begin{
    $osver = Get-ItemProperty -Path "HKLM:\software\microsoft\windows nt\currentversion" 
    $insider = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsSelfHost\Applicability"


    switch($insider.Ring)
    {
        "WIS"  {$InsiderLevel = "Slow"};
        "WIF"  {$InsiderLevel = "Fast"};
        "RP"   {$InsiderLevel = "Release Preview"};
        Default {$InsiderLevel = "not found"}
        }
}

Process{

        $props = [ordered]@{
        "ProductName" = $osver.ProductName
        "CompositionEditionID" = $osver.CompositionEditionID
        "ReleaseID" = $osver.ReleaseID
        "BuildBranch" = $osver.BuildBranch
        "CurrentBuild" = $osver.CurrentBuild
        "CurrentBuildNumber" = $osver.CurrentBuildNumber
        "BuildLabEx" = $osver.BuildLabEx
        "CurrentVersion" = $osver.CurrentVersion
        "UBR" = $osver.UBR
        "CurrentMajorVersionNumber " = $osver.CurrentMajorVersionNumber
        "CurrentMinorVersionNumber" = $osver.CurrentMinorVersionNumber
        "PreviewBuildsEnabled" = $insider.EnablePreviewBuilds 
        "InsiderLevel" = $InsiderLevel
        }
        $Results += @(New-Object pscustomobject -Property $props)
}

End
{
   $Results
}
}




