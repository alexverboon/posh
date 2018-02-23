Function Get-GpoExtensionInfo{
<#
.SYNOPSIS
    Get-GpoExtensionInfo
.DESCRIPTION
    Get-GpoExtensionInfo retrieves the following Group Policy Extension
    information from the local computer. 

    Name, Description, GUID

.EXAMPLE
    Get-GpoExtensionInfo

    The above command retrieves Group Policy Extension information. 

.NOTES
    v1, 23.02.2018, alex verboon
#>


Begin{
    Try{
    $GpoReportingDll = (Get-ChildItem -Path "C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Microsoft.GroupPolicy.Reporting\*.dll" -Recurse).fullname
    Add-Type -Path  "$GpoReportingDll"
    }
    Catch{
        Write-Error "Unable to load Microsoft.GroupPolicy.Reporting.dll"
        Throw
    }
}

Process{
    $GpoExtensionInfo = @()
    $GpoExtensionNames = ([Microsoft.GroupPolicy.Reporting.ExtensionNames].GetFields()).Name
    ForEach ($ExtN in $GpoExtensionNames)
    {
        $ExtName = [Microsoft.GroupPolicy.Reporting.ExtensionNames]::$ExtN
        $ExtGUID = [Microsoft.GroupPolicy.Reporting.ExtensionIDs]::$ExtN

        $object = [ordered]@{
        Name = $ExtN
        Description = $ExtName
        GUID = $ExtGUID
        }
        $GpoExtensionInfo += (New-Object -TypeName psobject -Property $object)
    }
}

End{
    $GpoExtensionInfo
}
}


