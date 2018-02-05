Function Update-CISVulnDefinitions {
<#
.SYNOPSIS
    Update-CISVulnDefinitions
.DESCRIPTION
    Update-CISVulnDefinitions downloads the Windows 7 and Windows 10
    vulnerability definitions. This is an alternative method instead of
    using the CISCAT -upo option. 
.PARAMETER Path
    The location where Windows Vulnerability definitions are stored locally.  
.EXAMPLE
    Update-CISVulnDefinitions -Path C:\TEMP\CISCAT
.NOTES
    
.LINK
    https://oval.cisecurity.org/
#>
    [CmdletBinding()]
    Param (        
        [Parameter(Mandatory=$true,Position=1)]
        [string]$Path)
Begin {
    #https://www.ssllabs.com/ssltest/analyze.html?d=www.verboon.info&latest
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $WinVulnDefUri = "https://oval.cisecurity.org/repository/download/5.10/vulnerability/"
    $CIS_VulnDef_Dir="cis-cat-full\third-party-content\org.mitre.oval"
    $RandomName = (([GUID]::NewGuid()).guid)

    If ((Test-Path "$Path\$CIS_VulnDef_Dir" -PathType Container) -eq $false)
    {
        Write-Verbose "$Path\$CIS_VulnDef_Dir does not exist, creating it now"
        New-Item -Path "$Path\$CIS_VulnDef_Dir" -ItemType Container | Out-Null
    }
}

Process {
    $WinVulnDefUriContent = Invoke-WebRequest -Uri $WinVulnDefUri -UseDefaultCredentials
    $Downloadlinks = ($WinVulnDefUriContent.Links | Select-Object href | Where-Object {$_.href -like "*Microsoft_windows_10.xml" -or $_.href -like "*Microsoft_Windows_7.xml"}).href

    ForEach($osuri in $downloadlinks)
    {
        $downloadfilename = Split-Path $osuri -Leaf
        Write-Verbose "Downloading Source: $downloadfilename"
        Write-Verbose "Target: $Path\$CIS_VulnDef_Dir\$RandomName`_$downloadfilename"
        $dltask = Invoke-WebRequest -Uri $osuri -Method Get -OutFile "$Path\$CIS_VulnDef_Dir\$RandomName`_$downloadfilename" 
    }

    # Gather the downloaded files
    $DownloadedFiles = Get-ChildItem -Path "$Path\$CIS_VulnDef_Dir" -Filter "$RandomName*.xml" 
    # The OVAL XML file must contain the following XML nodes
    $oval_requirednodes = @(
    "generator",
    "definitions",
    "tests",
    "objects",
    "states",
    "variables")

    $Result = @()                
    ForEach ($checkfile in $DownloadedFiles)
    {
        Write-Verbose "File: $($checkfile.FullName)"
        [xml]$vuldeffile = Get-Content -Path "$($checkfile.FullName)" 
        $xmlnodes = ($vuldeffile.oval_definitions.ChildNodes | Select-object Name).Name
        $checkovalschema = Compare-Object -ReferenceObject $oval_requirednodes -DifferenceObject $xmlnodes
        If ($check -ne $null )
        {
            Write-Warning "XML file does not seem to have the right nodes"
        }
        Else
        {
            $NewFileName = $checkfile.FullName -replace "$RandomName`_",""
            Write-Verbose "New FileName: $NewFileName"
            If (Test-Path $NewFileName)
            {
                Remove-Item -Path $NewFileName -Force
            }
            Rename-Item -Path $checkfile.FullName -NewName $NewFileName 
            $Result = $Result + $NewFileName
        }
    }
}

End {
        $Result
    }
}

