Function Get-CISBenchMarkProfiles {
<#
.SYNOPSIS
    Get-CISBenchMarkProfiles
.DESCRIPTION
    Get-CISBenchMarkProfiles list the available Profiles that are available for the 
    selected CIS Benchmark. 
.PARAMETER CISCATPath 
    The Path where CIS-CAT is installed
.PARAMETER BenchMark
    The name of the Benchmark. List is automatically populated based on content within 
    the CIS-CAT Benchmark folder. 

    Use this script to identify the available profiles when updating, extending the INvoke=CISCAT cmdlet code. 

.EXAMPLE
    Get-CISBenchMarkProfiles -CISCATPath C:\temp\CISTEMP -Benchmark CIS_Microsoft_Windows_10_Enterprise_Release_1703_Benchmark_v1.3.0-xccdf.xml

    The above command lists all profiles that are availble for the selected CIS Benchmark. 

    xccdf_org.cisecurity.benchmarks_profile_Level_1
    xccdf_org.cisecurity.benchmarks_profile_Level_1__BitLocker
    xccdf_org.cisecurity.benchmarks_profile_Level_2
    xccdf_org.cisecurity.benchmarks_profile_Level_2__BitLocker

.NOTES
    version 1.0, 23.01.2014, alex verboon
.LINK
    https://oval.cisecurity.org/
#>
    [CmdletBinding()]
    Param(
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
        }})]
        [string]$CISCATPath
    )  
    
  DynamicParam {
        
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
            $arrSet = Get-ChildItem -Path "$CISCATPath\CIS-CAT-FULL\Benchmarks" -Filter "*.xml"
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
        }


Begin {

}

Process{
    $BenchMarkFile = "$CISCATPath\CIS-CAT-FULL\Benchmarks\$($PSBoundParameters["BenchMark"])"
    Try{
    [xml]$BenchmarkContent = Get-Content -Path $BenchMarkFile
    }
    Catch{
        Write-error $_.Exception.Message
    }
}

End{
    Write-Verbose "Available Profiles in Brenchmark: $($PSBoundParameters["BenchMark"])"
    $BenchmarkContent.Benchmark.Profile | Select-Object -ExpandProperty ID
}
}