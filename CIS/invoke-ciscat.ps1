Function Invoke-CISCat {
<#
.SYNOPSIS
    Invoke-CISCAT triggers Configuration and Vulnerability Assessments
.DESCRIPTION
    Invoke-CISCAT triggers Configuration and Vulnerability Assessments
.PARAMETER Action 
    Defines whether the the cmdlet invokes CIS-CAT to run a Configuration Baseline
    or Vulnerability Assessment or uupdate the Vulnerability definitions
.EXAMPLE
    Invoke-CISCat -Action ConfigBaseline -CISCATPath C:\TEMP\CISCAT -Benchmark 'Windows 10' -Verbose

    The above command triggers the Benchmark assessment for the selected Benchmark and stores the results
    into the Reports folder located within the CIS-CAT Toolkit folder. 

.EXAMPLE
    Invoke-CISCat -Action Vulnerabilities -CISCATPath C:\temp\CISTEMP -Verbose

    The above command triggers the Vulnerability assessment for the underlying Operating System
    and stores the results into the Reports folder located within the CIS-CAT Toolkit folder. 

.EXAMPLE
    Invoke-CISCat -Action UpdateVulnerabilityDefinitions -CISCATPath c:\temp\cis -Verbose

    The above command updates the Vulnerability Definitions for all target systems

.NOTES
    version 1.1, 05.02.2018, alex verboon

.LINK
    https://oval.cisecurity.org
    https://www.cisecurity.org/cis-benchmarks/
#>
    [CmdletBinding()]
    Param (        
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateSet('ConfigBaseline','ScanVulnerabilities',"UpdateVulnerabilityDefinitions")]       
        [string]$Action,

        [Parameter(Mandatory=$true,Position=2)]
        [ValidateScript(
        {
            if ((Test-Path "$_\cis-cat-full\CISCAT.jar")) 
            { 
                write-verbose "$_\cis-cat-full\CISCAT.jar found"
                $true
            }
            else 
            {
                Throw "Unable to find $_\cis-cat-full\CISCAT.jar." 
            }
        })]
        [string]$CISCATPath
    )     

  DynamicParam {
        If ($Action -eq "ConfigBaseline")
        {
            # Set the dynamic parameters' name
            $ParameterName = 'Benchmark'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 3

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = "Windows 10","Office 2016","Access 2016","Excel 2016","Outlook 2016","PowerPoint 2016","Word 2016","Google Chrome","Mozilla FireFox 38 ESR"
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
        }
    }

Begin {

    $DebugMode = 0
    If ($PSBoundParameters.Keys -contains "Verbose")
    {
        write-verbose "verbose enabled"
        $DebugMode=1
    }
    
    # random part of filename for log file     
    $RandomName = (([GUID]::NewGuid()).guid)

    $BaseDir = $CISCATPath
    $CISCATAppPath = "$BaseDir\cis-cat-full"
    $DebugLogFile = "$BaseDir\cis-debug-log_$RandomName.log"
    $JavaExePath = "$BaseDir\java\jre32\bin\java.exe"
    $JavaMaxMemory = 1028
    $cis_options = "-x -t -csv"


    <#
        CIS-CAT Tool command line options
        # -a = accept terms
        # -aa = auto assessment
        # -arf = creates an arf report
        # -as = report agregration report status
        # -b = path to benchmark to run
        # -csv = create csv report
        # -l = list available benchmarks
        # -n = no html report creation
        # -or = oval results HTML report
        # -orx = oval results xml report
        # -p = benchmark profile
        # -r = report output directory
        # -s = show status information
        # -t = create text report
        # -up = download latest vulnerability definitions
        # -upo = download latest vulneratbility defintions for current OS
        # -va = Execute a Vulnerability Assessment and generate a vulnerability results HTML report 
        # -vac = same as above but outputs CSV
        # -vs = verify benchmark are valid
        # -y = show all tests


    #>


   
        If (Test-Path "$CISCATPath\Reports")
        {
            Write-Verbose "$CISCATPath\Reports folder already exists"
        }
        Else
        {
            Write-Verbose "Creating Reports output folder: $CISCATPath\Reports"
            New-Item -Path "$CISCATPath\Reports" -ItemType Directory -Force | Out-Null
        }


    # Configuration Baseline
    Write-Verbose "CIS-CAT Action: $Action"

    If ($Action -eq "ConfigBaseline")
    {
        Write-Verbose "Selected Benchmark $($PSBoundParameters["BenchMark"])"


        If ($PSBoundParameters["BenchMark"] -eq "Windows 10")
        {
            $BenchMarkName = "CIS_Microsoft_Windows_10_Enterprise_Release_1703_Benchmark_v1.3.0-xccdf.xml"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_2__BitLocker"
        }
        ElseIf ($PSBoundParameters["BenchMark"] -eq "Office 2016")
        {
            $BenchMarkName = "CIS_Microsoft_Office_2016_Benchmark_v1.1.0-xccdf.xml"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_1"
        }
        Elseif ($PSBoundParameters["BenchMark"] -eq "Access 2016")
        {
            $BenchmarkName = "CIS_Microsoft_Office_Access_2016_Benchmark_v1.0.1-xccdf.xml"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_1"
        }
        Elseif ($PSBoundParameters["BenchMark"] -eq "Excel 2016")
        {
            $BenchmarkName = "CIS_Microsoft_Office_Excel_2016_Benchmark_v1.0.1-xccdf.xml"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_1"
        }
        Elseif ($PSBoundParameters["BenchMark"] -eq "Outlook 2016")
        {
            $BenchmarkName = "CIS_Microsoft_Office_Outlook_2016_Benchmark_v1.1.0-xccdf.xml"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_1"
        }
        Elseif ($PSBoundParameters["BenchMark"] -eq "PowerPoint 2016")
        {
            $BenchmarkName = "CIS_Microsoft_Office_PowerPoint_2016_Benchmark_v1.0.1-xccdf.xml"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_1"
        }
        Elseif ($PSBoundParameters["BenchMark"] -eq "Word 2016")
        {
            $BenchmarkName = "CIS_Microsoft_Office_Word_2016_Benchmark_v1.1.0-xccdf.xml"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_1"
        }
        
        Elseif ($PSBoundParameters["BenchMark"] -eq "Google Chrome")
        {
            $BenchmarkName = "CIS_Google_Chrome_Benchmark_v1.2.0-xccdf.xml"
            #$BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_1"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_2"
        }
        
        Elseif ($PSBoundParameters["BenchMark"] -eq "Mozilla FireFox 38 ESR")
        {
            $BenchmarkName = "CIS_Google_Chrome_Benchmark_v1.2.0-xccdf.xml"
            #$BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_1"
            $BenchMarkProfile = "xccdf_org.cisecurity.benchmarks_profile_Level_2"
        }
        Else
        {
            Throw "Unknown Benchmark specified"
        }
        $cmdline = @("-Xmx$JavaMaxMemory`M -jar $CISCATAppPath\ciscat.jar -a -s -y $cis_options -b $CISCATAppPath\Benchmarks\$BenchmarkName -p $BenchMarkProfile -r $CISCATPath\Reports")
   
    }
    Elseif ($Action -eq "ScanVulnerabilities")
    {
        $cmdline = @("-Xmx$JavaMaxMemory`M -jar $CISCATAppPath\ciscat.jar -a -s -y $cis_options -va -r $CISCATPath\Reports")
    }
    Elseif ($Action -eq "UpdateVulnerabilityDefinitions")
    {
        $cmdline = @("-Xmx$JavaMaxMemory`M -jar $CISCATAppPath\ciscat.jar -a -s -up")
    }

    Else
    {
        Write-Error "No Action Defined!"
        Throw
    }
}


Process {
        If ($Action -eq "ConfigBaseline" -or $Action -eq "ScanVulnerabilities" -or $Action -eq "UpdateVulnerabilityDefinitions")
        {
            Write-Verbose "Java: $JavaExePath"
            Write-Verbose "cmdline: $cmdline"

            $result = $null
            $log = $null
            $psi = New-object System.Diagnostics.ProcessStartInfo 
            $psi.CreateNoWindow = $true 
            $psi.UseShellExecute = $false 
            $psi.RedirectStandardOutput = $true 
            $psi.RedirectStandardError = $true 
            $psi.FileName = "$JavaExePath" 
            $psi.Arguments = @("$cmdline") 
            $process = New-Object System.Diagnostics.Process 
            $process.StartInfo = $psi 
            [void]$process.Start()
            do
            {
               #$process.StandardOutput.ReadLine()
               $log = ($process.StandardOutput.ReadLine())

               If (-not ([string]::IsNullOrEmpty($log)))
               {
                   write-host $log -ForegroundColor Green
                   $Result = $Result + $log + "`r `n"
               }
            }
            while (!$process.HasExited)
        }
}
  

End {

    If ($log -like "*ERR-CLI*")
    {
        $CIS_Error = ($log.Split(":").TrimStart()[1])

        switch($CIS_Error)
        {
            "ERR-CLI-0002" {$CIS_err_msg = "An unrecognized Command-Line option was entered. Use -h to list all available CommandLine options"} 
            "ERR-CLI-0002" {$CIS_err_msg = "An error occurred parsing the available Command-Line options.  Please contact CIS-CAT support"}
            "ERR-CLI-0003" {$CIS_err_msg = "An error occurred when attempting to connect to the database. (Error message is included)"}
            "ERR-CLI-0004" {$CIS_err_msg = "An error occurred configuring the reports directory.  The directory does not exist.  Either create this directory or specify a valid directory"} 
            "ERR-CLI-0005" {$CIS_err_msg = "An error occurred configuring the HTTP POST URL (url value).  Please ensure this URL exists and is reachable"}
            "ERR-CLI-0006" {$CIS_err_msg = "An error occurred configuring the dashboard report source directory.  (directory name) does not exist.  Specify a valid directory containing the XML reports to be aggregated."}
            "ERR-CLI-0007" {$CIS_err_msg = "An error occurred reading the benchmark file (name of benchmark file).  Ensure a valid benchmark file is selected."}
            "ERR-CLI-0008" {$CIS_err_msg = "An error occurred parsing the benchmark file (name of benchmark file).  Ensure a valid benchmark file is selected."}
            "ERR-CLI-0009" {$CIS_err_msg = "The User chose to exit CIS-CAT"}
            "ERR-CLI-0010" {$CIS_err_msg = "An error occurred configuring the data stream selected for assessment.  Ensure the data stream is valid for the selected benchmark"}
            "ERR-CLI-0011" {$CIS_err_msg = "An error occurred configuring the checklist selected for assessment.  Ensure the checklist is valid for the selected benchmark"}
            "ERR-CLI-0012" {$CIS_err_msg = "An error occurred configuring the profile selected for assessment.  Ensure the profile is valid for the selected benchmark"}
            "ERR-CLI-0013" {$CIS_err_msg = "An error occurred loading the available benchmarks from (benchmark source directory)."}
            "ERR-CLI-0014" {$CIS_err_msg = "When the checklist option (-xc) is entered, a valid data stream selection (-ds) must also be entered."}
            "ERR-CLI-0015" {$CIS_err_msg = "When the OVAL Variables file option (-ov) is entered, a valid OVAL Definitions file option (-od) must also be entered."}
            "ERR-CLI-0016" {$CIS_err_msg = "An invalid Command-Line option combination has been entered.  Use -h to list all available Command-Line options"}
            "ERR-CLI-0017" {$CIS_err_msg = "An error occurred loading available OVAL Definitions from (source directory). "}
            "ERR-CLI-0018" {$CIS_err_msg = "An error occurred reading the OVAL Definitions file (filename).  Ensure a valid OVAL Definitions file is selected."}
            "ERR-CLI-0019" {$CIS_err_msg = "An error occurred reading the OVAL Variables file (filename).  Ensure a valid OVAL Variables file is selected."}
            "ERR-CLI-0020" {$CIS_err_msg = "The User did not accept the CIS-CAT Terms of Use.  Use the -a option to accept the Terms of Use."}
            "ERR-CLI-0021" {$CIS_err_msg = "An invalid selection was made.  CIS-CAT will now exit."}
            "ERR-CLI-0022" {$CIS_err_msg = "An error occurred configuring ad-hoc report generation.  The file/directory (directory name) does not exist"}
            "ERR-CLI-0023" {$CIS_err_msg = "not defined in reference guide"}
            "ERR-CLI-0024" {$CIS_err_msg = "An error occurred when attempting to connect to the ESXi host.  The host may be unreachable or the user/password could be invalid."}
            "ERR-CLI-0025" {$CIS_err_msg = "The selected benchmark does not match the target platform."}
            "ERR-CLI-0026" {$CIS_err_msg = "An error occurred when attempting to establish an SSH session.  The host may be unreachable or the user/password/port could be invalid"}
            default {"Unknown error"}
        }
    Write-Warning "$CIS_err_msg"
    }
    Elseif($log -like "*error*")
    {
        # sometimes we can't catch the exact error code, so we add a fallback
        Write-Warning "There was an error"
    }
    ElseIf($log -like "*Evaluation*")
    {
        write-output "CIS-CAT Processing completed"
    }

    If ($DebugMode -eq 1)
    {
        $Result | out-file $DebugLogFile
    }

 }
}

