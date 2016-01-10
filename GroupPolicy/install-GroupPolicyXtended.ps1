# URL to .psm1 file
$Url = "https://raw.githubusercontent.com/alexverboon/posh/master/GroupPolicy/GroupPolicyXtended.psm1"

function Install-ModuleFromUri {
    Param([Parameter(Mandatory=$true,Position=0)][string]$Uri)

    # File name of URL without extension
    $modname = (([System.Uri]"$Uri".Replace("?raw","")).Segments[-1]).Split(".")[0]

    # Create local module path
    $modpath = [environment]::getfolderpath("mydocuments") + `
                   "\WindowsPowerShell\Modules\$modname"

    # Create module folder(s) if it doesn't exist
    if (!(Test-Path $modpath)) {
        New-Item -itemtype "Directory" $modpath -force | Out-Null
    }

    # Download module
    Invoke-WebRequest $Uri -OutFile "$modpath\$modname.psm1" -UseDefaultCredential 

    # Import so it becomes immediately loaded
    Import-Module "$modpath\$modname.psm1" -Force
    Write-Output "Done installing $modname!`n"
    Write-Output "Installed from: $Uri"
    Write-Output "Installed to:   $modpath`n"
    Write-Output "Run `"gcm -m $modname`" to get a list of features."
}

Install-ModuleFromUri -Uri "$Url"
