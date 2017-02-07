function Select-MyAzureRmSubscription
{
<#
.Synopsis
   Select-MyAzureRmSubscription
.DESCRIPTION
The Select-MyAzureRmSubscription cmdlet provides an easy way to select an Azure Subscription
and sets authentication information for cmdlets that you run in the current session.
The context includes tenant subscription, and environment information.

.PARAMETER SubscriptionName
A list of Subscriptions that the connected user has access to. 
The cmdlet dynamically builds a list of accessible subscriptions

.EXAMPLE
Select-MyAzureRmSubscription -SubscriptionName 'Visual Studio Professional with MSDN' -verbose

Sets the context to the Subscription 'Visual Studio Professional with MSDN' 

VERBOSE: Selected SubscriptionName: Visual Studio Professional with MSDN
VERBOSE: Setting Azure Context to Visual Studio Professional with MSDN

Environment           : AzureCloud
Account               : user1@outlook.com
TenantId              : f2108ecc-dd4a-4b24-9f58-8b309a9a9a09
SubscriptionId        : 46327b72-b63c-48dd-b7f9-8f9031a876f2
SubscriptionName      : Visual Studio Professional with MSDN
CurrentStorageAccount : 


.NOTES
    Connec to Azure using Login-AzureRmAccount prior using this function

    Version 1.0, 21.12.2016, Alex Verboon
  
#>
    [CmdletBinding()]
    Param()
    DynamicParam {
        $attributes = new-object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = "__AllParameterSets"
        $attributes.Mandatory = $false
        $attributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)

        $_Values = ((Get-AzureRmSubscription | select-object SubscriptionName | Sort-object Name).SubscriptionName) 

        If ([string]::IsNullOrEmpty($_Values))
        {
            Write-Error "No Subscriptions found, check your connectivity to Azure"
            Throw
        }

    $ValidateSet = new-object System.Management.Automation.ValidateSetAttribute($_Values)
    $attributeCollection.Add($ValidateSet)
    $SubscriptionName =  new-object -Type System.Management.Automation.RuntimeDefinedParameter("SubscriptionName", [string], $attributeCollection)
    $paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $paramDictionary.Add("SubscriptionName", $SubscriptionName)

    return $paramDictionary }

    Begin{
        $SubscriptionName = $SubscriptionName.Value 
        Write-Verbose "Selected SubscriptionName: $SubscriptionName"
    }
    Process{
        Write-verbose "Setting Azure Context to $SubscriptionName"
        Select-AzureRmSubscription -SubscriptionName "$SubscriptionName"
    }
    End{}
}
