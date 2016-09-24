

function Start-AppCert
{
<#
.Synopsis
   Sart-AppCert executes the Windows App Certification Kit Test process for the
   specified application and retrurns the test results. 

.DESCRIPTION
    The Start-AppCert cmdlet launches the Windows App Certification Kit that runs
    the following tests for the specified software. 

    1      Clean reversible install test            
    2      Install to the correct folders test      
    3      Digitally signed file test               
    4      Support x64 Windows test                 
    5      OS version checking test                 
    6      User account control (UAC) test          
    7      Adhere to system restart manager messages
    8      Safe mode test                           
    9      Multiuser session test                   
    10     Deployment and launch tests              
    11     Compatibility and resiliency test        
    14     Windows security features test           
    26     High-DPI support  

    For more deails see:
    https://msdn.microsoft.com/en-us/library/windows/desktop/mt674655.aspx
    https://msdn.microsoft.com/en-us/library/mt637085(v=vs.85).aspx

.EXAMPLE
   Start-AppCert -SetupPath C:\data\7z1602-x64.msi -SetupCmdLine /quiet

    Name                                                   Result  Description                           
    ----                                                   ------  -----------                           
    Remove all non-shared files and folders                PASS    All newly installed programs were p...
    Do not force an immediate reboot during installation   PASS    Users should have the opportunity t...
    Do not force an immediate reboot during uninstallation PASS    Users should have the opportunity t...
    Write appropriate Add/Remove Program values            WARNING Write appropriate Add/Remove Progra...
    Single user registry check                             PASS    Checks invalid writes to registry o...
    Install to Program Files                               WARNING Install to Program Files description. 
    Write to the %WINDIR% or %SystemDrive%                 PASS    Write to the %WINDIR% or %SystemDri...
    Loading apps on Windows startup                        PASS    Loading apps on Windows startup.      
    Install signed driver and executable files             WARNING Install signed driver and executabl...
    Install platform specific files, and drivers           PASS    Install platform specific files, an...
    Proper OS version checking                             FAIL    Perform proper OS version checking ...
    User account control run level                         WARNING Windows® applications must have a m...
    Don't block reboot                                     PASS    Don't block reboot.                   
    Do not load services and drivers in safe mode          PASS    By default, most drivers and servic...
    Multi user check logs                                  PASS    Multi User checks App-Verifier logs.  
    Multi user registry check                              PASS    Checks invalid writes to registry o...
    Do not write to the 'Users' folder                     PASS    Do not write to the 'Users' folder.   
    Crashes and hangs                                      PASS    Do not crash or hang during the tes...
    Compatibility fixes                                    PASS    Compatibility fixes.                  
    User mode hooking using AppInit_DLLs                   PASS    User mode hooking using AppInit_DLLs. 
    Compatibility manifest                                 WARNING Windows® applications must have a c...
    Binary analyzer                                        WARNING Analysis of security features enabl...
    High-DPI                                               PASS    Win32 applications should set DPI-a...

.EXAMPLE
   Start-AppCert -SetupPath C:\data\winzip20_downwz.exe


    Name                                                   Result  Description                           
    ----                                                   ------  -----------                           
    Remove all non-shared files and folders                PASS    All newly installed programs were p...
    Do not force an immediate reboot during installation   PASS    Users should have the opportunity t...
    Do not force an immediate reboot during uninstallation PASS    Users should have the opportunity t...
    Write appropriate Add/Remove Program values            PASS    Write appropriate Add/Remove Progra...
    Single user registry check                             PASS    Checks invalid writes to registry o...
    Install to Program Files                               PASS    Install to Program Files description. 
    Write to the %WINDIR% or %SystemDrive%                 WARNING Write to the %WINDIR% or %SystemDri...
    Loading apps on Windows startup                        WARNING Loading apps on Windows startup.      
    Install signed driver and executable files             WARNING Install signed driver and executabl...
    Install platform specific files, and drivers           PASS    Install platform specific files, an...
    Proper OS version checking                             FAIL    Perform proper OS version checking ...
    User account control run level                         PASS    Windows® applications must have a m...
    Don't block reboot                                     WARNING Don't block reboot.                   
    Do not load services and drivers in safe mode          PASS    By default, most drivers and servic...
    Multi user check logs                                  PASS    Multi User checks App-Verifier logs.  
    Multi user registry check                              PASS    Checks invalid writes to registry o...
    Do not write to the 'Users' folder                     PASS    Do not write to the 'Users' folder.   
    Crashes and hangs                                      FAIL    Do not crash or hang during the tes...
    Compatibility fixes                                    PASS    Compatibility fixes.                  
    User mode hooking using AppInit_DLLs                   PASS    User mode hooking using AppInit_DLLs. 
    Compatibility manifest                                 PASS    Windows® applications must have a c...
    Binary analyzer                                        WARNING Analysis of security features enabl...
    High-DPI                                               PASS    Win32 applications should set DPI-a...

.NOTES
    24.09.2016 by Alex Verboon
#>

    [CmdletBinding()]
    Param
    (
        # The path to the Application instalaltion file (MSI / EXE)
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$SetupPath,

        # The installation commandline option: Example /quiet
       [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$SetupCmdLine
    )

    Begin
    {

    # Reports Path
    $mydocuments = [environment]::getfolderpath("mydocuments")
    $AppCertReportDirectory = "$mydocuments\AppCertReports"
    # App Certification Toolkit Executable
    $AppCertTool = "C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe" 
    $AppCertToolPath = Split-Path -Path $AppCertTool

    Set-Location $AppCertToolPath

    # Check if App Certification Toolkit is installed
    If ((Test-Path -Path $AppCertTool) -eq $false)
    {
        Write-Error "Microsoft Appliction Certification Toolkit is not installed on this computer"
        Throw
    }

    # Check Reports Path, create folder if it does not exist
    If ((Test-Path -Path $AppCertReportDirectory) -eq $false )
    {
        New-Item -Path $AppCertReportDirectory -ItemType Directory 
    }

    #Appcert settings
    $AppType = "Desktop" 
    $WaitTimeOut = "900" 
    $AppUsage = "permachine" 

    # Report Filename
    $ReportOutPath = "$AppCertReportDirectory\" + (($SetupPath -split "\\")[-1] + ".xml")

    # Check if application report already exists, if so, delete it
    If ((Test-Path -Path $ReportOutPath) -eq $true )
    {
        Write-Verbose "$ReportOutPath already exists, deleting file"
        Remove-Item -Path $ReportOutPath
    }

    # Build the command line to run appcert
    If ([string]::IsNullOrEmpty($SetupCmdLine))
    {
        $AppCertCmdStr = ".\appcert.exe test -apptype " + $apptype + " -setuppath " + "'$setuppath'" + " -waittimeout " + $waittimeout + " -appusage " + $AppUsage +" -reportoutputpath " +  "'$ReportOutPath'"
    }
    Else
    {
        $AppCertCmdStr = ".\appcert.exe test -apptype " + $apptype + " -setuppath " + "'$setuppath'" + " -setupcommandline " + "'$SetupCmdLine'" + " -waittimeout " + $waittimeout + " -appusage " + $AppUsage +" -reportoutputpath " +  "'$ReportOutPath'"
    }

    $AppCertCmd = $AppCertCmdStr -replace "'",'"'

    #Build the command line to run the final report
    $FinalReportCmdStr = ".\appcert.exe finalizereport -reportfilepath " + "'$ReportOutPath'"
    $FinalReportCmd = $FinalReportCmdStr -replace "'",'"'
    }

    Process
    {
    # Run appcert
    Write-Verbose "Executing $AppCertCmd"
    invoke-expression -command "$AppCertCmd" -OutVariable $runcert 

    # Generate the final report
    Write-Verbose "Executing $FinalReportCmd" 
    Invoke-Expression -Command "$FinalReportCmd" -OutVariable $runfinalreport

    }
    End
    {

    $report = Get-Content -Path $ReportOutPath
    $reportdata = [xml]$report

    $AppInfo = $reportdata.REPORT.APPLICATIONS.Installed_Programs.Program
    Write-verbose "$($AppInfo)"

    $AllTests = $reportdata.REPORT.REQUIREMENTS.REQUIREMENT.TEST

    $certdata = @()
    ForEach ($test in $AllTests)
    {
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name Name -Value $test.name
        $object | Add-Member -MemberType NoteProperty -Name Result -Value $test.Result.'#cdata-section'
        $object | Add-Member -MemberType NoteProperty -Name Description -Value $test.Description
        $object | Add-Member -MemberType NoteProperty -Name Index -Value $test.Index
        $certdata += $object
   }

   $certdata

}

}

