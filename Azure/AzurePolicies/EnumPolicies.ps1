
Function Get-xAzureRmPolicySetDefinitionDetails
{
<#

#>

[CmdletBinding()]

Param()

Begin{

    Try{
    $AzPolSetDef = Get-AzureRmPolicySetDefinition 
    }
    Catch
    {
        Write-error "Unable to retrieve Azure Policy Definitions"
        Throw
    }

}

Process{
    ForEach ($PolSet in $AzPolSetDef)
    {
        Write-Verbose "Processing $($polset.displayName)"

        # Get all all PolicyDefintiions included in the PolicySet
        $includedpoldef = ($PolSet.Properties.policyDefinitions).policyDefinitionId
    
        $Result = @()
        ForEach ($Azpoldef in $includedpoldef)
        {
            $def = Get-AzureRmPolicyDefinition -Id $Azpoldef 
        
            $object = [ordered] @{
            PolicySetDefName = $PolSet.Name
            PolicySetDefID = $Polset.PolicySetDefinitionId
            PolicySetDefDisplayName = $Polset.Properties.displayName
            PolicySetDefResourceID = $polset.ResourceId
            PolicyDefID = $def.PolicyDefinitionId
            PolicyDefResourceID = $def.ResourceId
            PolicyName = $def.Name
            PolicyID = $def.PolicyDefinitionId
            PolicyDescription = $def.Properties.description
            PolicyDisplayName = $def.Properties.displayName
            PolicyCategory = $def.Properties.metadata.category
            PolicyMode = $def.Properties.mode
            PolicyParam = $def.Properties.parameters
            PolicyRuleIf = $def.Properties.policyRule.if
            PolicyRuleThen = $def.Properties.policyRule.then
            PolicyType = $def.Properties.policyType
        }
        $Result += (New-Object -TypeName PSObject -Property $object)
       }
    }
}

End{
    $Result
}
}