
Function Install-CISCATToolkit{
<#
.SYNOPSIS
    Install-CISCATToolkit
.DESCRIPTION
    Install-CISCATToolkit Downloads and installs the CIS Configuration Assessment Toolkit"
.PARAMETER Path 
    The Path where CIS-CAT will be installed
.EXAMPLE
     Install-CISCATToolkit -Path C:\TEMP\CISCAT
.NOTES
    version 1.0, 23.01.2018, alex verboon
#>

    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true,Position=1)]
    [string]$Path
    )

    Begin{

    # Create the CIS-CAT Toolkit Folder
    If (Test-Path -Path $Path -PathType Container)
    {
        Write-Warning "Folder $Path already exists, please specify another folder or delete this folder first"
        Throw
    }
    Else
    {
        New-Item -Path "$Path" -ItemType Directory | Out-Null
    }


}

Process{
    Try{
        # Pointer to latest CIS-CAT Toolit Bundle
    

        $CISBundleZip = "https://<location>/repos/ciscat/raw/CIS-CAT-Toolkit/Latest/cis-cat-dissolvable.zip?at=refs%2Fheads%2Fmaster"
        Write-Output "Locating CIS-CAT Toolkit source: $CISBundleZip"

        # Check if file exists
        $CheckIt = Invoke-WebRequest $CISBundleZip -Method Head
        If (-not ($CheckIt.StatusCode -eq 200))
        {
            Throw ("Unable to find $CISBundleZip")
        }
        Else
        {
            # Download the CIS-CAT Toolkit Archive
            Write-Output "Downloading CIS-CAT Toolkit Archive"
            Invoke-WebRequest -Uri $CISBundleZip -Method get -OutFile "$Path\cis-cat-dissolvable.zip" -UseDefaultCredentials

            # Extract the CIS-CAT ToolKit Archive
            Write-Output "Extracting $Path\cis-cat-dissolvable.zip to $Path"
            Expand-Archive -Path "$Path\cis-cat-dissolvable.zip" -DestinationPath "$Path" 

            # Verify correct expansion, we just check for the existence of a particular CIS-CAT file. 
            Write-Output "Verifying installtaion"
            If (Test-Path "$Path\cis-cat-full\CISCAT.jar" -PathType Leaf)
            {
                Write-Output "CIS-CAT Toolkit successfully installed in $Path"
            }
            Else
            {
                Throw ("$Path\cis-cat-full\CISCAT.jar could not be found")
            }
        }
    }
    Catch{
        Write-Warning "Something went wrong while downloading and installing CIS-CAT Toolkit"
        Write-error $_.Exception.Message
    }
}

End{
Write-Output "

You can now continue using the CIS-CAT Toolkit.

Use Update-CISVulnDefinitions to update the Vulnerability Assessment definitions

Use Invoke-CISCAT to start a Configuration Baseline or Vulnerability Assessment"
}
}


