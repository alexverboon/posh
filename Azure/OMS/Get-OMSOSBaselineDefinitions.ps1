
Function Get-OMSOSBaselineDefinitions {
<#
.SYNOPSIS
    Get-OMSOSBaselineDefinitions
.DESCRIPTION
    Get-OMSOSBaselineDefinitions lists Configuration data from the selected
    OMS Security configuration baseline definition file. 

    These files are stored wihtin subfolders under: 
    "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Resources"

.PARAMETER Baseline
    The filename of the OMS Security Configuration Baseline 

.EXAMPLE
    Get-OMSOSBaselineDefinitions -Baseline 'C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Resources\689\BaselineWindowsServer2016.xml'

    The above command lists all the Security Configuration Baseline definitions for
    the Windows Server 2016 operating system. 

.NOTES
    v1.0, 19.02.2018, alex verboon
#>
[CmdletBinding()]
Param(
 )

 DynamicParam {
        
            # Set the dynamic parameters' name
            $ParameterName = 'Baseline'
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            #$ParameterAttribute.Position = 3
            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)
            # Generate and set the ValidateSet 
            $BaseLinePath = "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Resources"
            $arrSet = Get-ChildItem -Path "$BaseLinePath\*BaseLine*.xml" -Recurse -Depth 2
            #$arrSet = Get-ChildItem -Path "$CISCATPath\CIS-CAT-FULL\Benchmarks" -Filter "*.xml"
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
        }

Begin{
  Write-verbose "Selected Baseline: $($PSBoundParameters["Baseline"])"
}

Process{
    $Result = @()
    $Rules = @("BaselineRegistryRule","BaselineAuditPolicyRule","BaselineSecurityPolicyRule")
    ForEach ($RuleType in $Rules)
    {
                write-verbose "Processing Rule: $RuleType"
                $blfile = "$($PSBoundParameters["Baseline"])"


                write-host "$($blfile.name)"
                If (-not ($blfile.name -eq "WebBaseLineRules.xml"))
                {
                    $Baselines = Select-xml -Path $blfile -XPath "//$RuleType"
                }
                Elseif ($blfile.Name -eq "WebBaseLineRules.xml")
                {
                    $Baselines = Select-xml -Path $blfile -XPath "//WebBaselineRule"
                    $RuleType = "WebBaselineRule"
                }

                ForEach ($BRule in $baselines.node)
                {
                    $object = [ordered] @{
                    BaselineFile = $blfile
                    RuleType = $RuleType
                    BaselineId  = $BRule.BaselineId     
                    Id = $BRule.Id         
                    OriginalId = $BRule.OriginalId   
                    CceId = $BRule.CceId
                    Name = $BRule.Name
                    Type = $BRule.Type
                    ExpectedValue = $BRule.ExpectedValue
                    Severity = $BRule.Severity
                    AnalyzeOperation = $BRule.AnalyzeOperation
                    Enabled = $BRule.Enabled
                    AuditPolicyId = $BRule.AuditPolicyId
                    }
                    $Result += (New-Object -TypeName PSOBJECT -Property $object)
                }
    }
}

End{
    $Result
}
}



