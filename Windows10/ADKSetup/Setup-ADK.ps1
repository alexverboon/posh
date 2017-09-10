function Setup-ADK
{
<#
.Synopsis
Setup-ADK provides ADK download and install options

.DESCRIPTION
The Setup-ADK cmdlet provides options to download or install an individual feature
from the Windows Assessment and Deployment Kit (ADK).
Before using this script download the ADKSetup.exe (download launcher) from
https://developer.microsoft.com/en-us/windows/hardware/windows-assessment-deployment-kit
and place the file in the script folder
example: C:\DEV\Utilities\SetupADK
Additional Information
https://developer.microsoft.com/en-us/windows/hardware/windows-assessment-deployment-kit
https://msdn.microsoft.com/windows/hardware/commercialize/what-s-new-in-kits-and-tools#windows-imaging-and-configuration-designer-icd
https://technet.microsoft.com/en-us/itpro/windows/manage/appv-install-the-sequencer
https://technet.microsoft.com/en-us/itpro/windows/manage/appv-release-notes-for-appv-for-windows
.PARAMETER Download
Instructs the cmdlet to run in download mode
.PARAMETER Path
The path where the downloaded ADK instalation sources are stored
.PARAMETER Install
Instructs the cmdlet to run in install mode
.PARAMETER Feature
The ADK feature to install
Note that the cmdlet only supports installing one feature at a time.
.PARAMETER ADKSource
The ADK installation source path
.EXAMPLE
Setup-ADK -Download -Path c:\temp\ADKSources
Starts the download and stores the sources in c:\temp\ADKSources
.EXAMPLE
Setup-ADK -Install -Feature UserStateMigrationTool -ADKSource c:\temp\ADKSources
.EXAMPLE
Setup-ADK -Install -Features "DeploymentTools","WindowsPreInstallationEnvironment","UserStateMigrationTool" -ADKSource $PSScriptRoot
Installs multiple features at once c:\temp\ADKSources


.NOTES
version 1.1, 19.01.2017, Alex Verboon
version 1.1  10.09.2017, Francois Fournier, added ability to install multiple features


#>
[CmdletBinding()]
Param
(
# Instructs the cmdlet to run in download mode
[Parameter(Mandatory=$true,ParameterSetName="Download",
Position=0)]
[switch]$Download,
    # The path where the downloaded ADK instalation sources are stored
    [Parameter(Mandatory=$true,ParameterSetName="Download",
        Position=1)]
    [string]$Path,

    # Instructs the cmdlet to run in install mode
    [Parameter(Mandatory=$true,ParameterSetName="Install",
    Position=0)]
    [switch]$Install,

    # The ADK feature to install
    [Parameter(Mandatory=$true,ParameterSetName="Install",
        Position=1)]
    [validateset("ApplicationCompatibilityToolKit","DeploymentTools",
    "WindowsPreInstallationEnvironment","ImagingAndConfigurationDesigner",
    "ICDConfigurationDesigner","UserStateMigrationTool","VolumeActivationManagementTool",
    "WindowsPerformanceToolkit","WindowsAssessmentToolkit",
    "WindowsAssessmentServicesClient","sqlExpress2012",
    "UEVTools","AppmanSequencer","MediaeXperienceAnalyzer"
    )]
    [string[]]$Features,

    # The ADK installation source path
    [Parameter(Mandatory=$true,ParameterSetName="Install",
    Position=2)]
    [string]$ADKSource
)
Begin
{

If (Get-Process -Name adksetup -ErrorAction SilentlyContinue)
{
    Write-Error "An instance of adksetup is already running"
    Break
}


if ($PSBoundParameters.ContainsKey("Download"))
{
    Write-Verbose "Checking download prerequisites"
    #Check if the adksetup.exe download launcher is present
    If (Test-Path "$PSScriptRoot\adksetup.exe")
    {
        Write-verbose "Adksetup.exe download launcher located"
        $AdkExe = "$PSScriptRoot\adksetup.exe"
    }
    Else
    {
        Write-Error "$PSScriptRoot\adksetup.exe could not be found"
        Break
    }
}


if ($PSBoundParameters.ContainsKey("Install"))
{
    Write-Verbose "Checking Installation prerequisites"
    #Check if the adksetup.exe installer is present
    If (Test-Path "$ADKSource\adksetup.exe")
    {
        Write-verbose "Adksetup.exe Install launcher located"
        $AdkExe = "$ADKSource\adksetup.exe"
    }
    Else
    {
        Write-Error "$ADKSource\adksetup.exe ADK Installer could not be found in $ADKSource"
        Break
    }
}


}
Process
{
    if ($PSBoundParameters.ContainsKey("Download"))
    {
        Write-output "Starting ADK Download to $Path"
        Write-output "Please wait, depending on your network connection this can take a few minutes"
        $AdkArgs = "/quiet /InstallPath $Path /layout $Path"
        $proc = Start-Process $AdkExe -ArgumentList $AdkArgs -PassThru -Wait
    }
    write-host "test"

    if ($PSBoundParameters.ContainsKey("Install"))
    {
        Write-output "Starting Install of $Features"

        #prefix Features with "OptionId."
        $Featurelist = $Features -replace "^","OptionId."

        $AdkArgs = "/features $FeatureList /quiet /norestart"
        $proc = Start-Process $AdkExe -ArgumentList $AdkArgs -PassThru -Wait
    }

}
End
{
      Write-Output "Completed"
}
}

