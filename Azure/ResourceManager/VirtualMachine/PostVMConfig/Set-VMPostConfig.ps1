

function Set-VMPostConfiguration
{
<#
.Synopsis
   Run Azure Windows VM Post Configuration 
.DESCRIPTION
   This script runs post configuration tasks on an Azure Windows VM. 
   
   - Add BGInfo Extension
   - Join the client to the domain
.PARAMETER VM 
 The name of the Azure Virtual Machine

.PARAMETER ResourceGroup
 The name of the Virtual Machine's Azure Resource group.

.EXAMPLE
    Set-VMPostConfiguration -VM VM2 -ResourceGroup RG_2
.NOTES
    24.09.2016 by Alex Verboon
#>

    [CmdletBinding()]
    Param
    (
        # The Name of the Virtual Machine
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$VM = "vm1"
        )

    # The Name of the ResourceGroup
    DynamicParam {
    $attributes = new-object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = "__AllParameterSets"
    $attributes.Mandatory = $true
    $attributeCollection =
      new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $attributeCollection.Add($attributes)
    $_Values = (Get-AzureRmResourceGroup).ResourceGroupName       
    $ValidateSet =
      new-object System.Management.Automation.ValidateSetAttribute($_Values)
    $attributeCollection.Add($ValidateSet)
    $dynParam1 =
      new-object -Type System.Management.Automation.RuntimeDefinedParameter(
      "ResourceGroup", [string], $attributeCollection)
    $paramDictionary =
      new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $paramDictionary.Add("ResourceGroup", $dynParam1)
    return $paramDictionary }

    Begin
    {
        $Location = "westeurope"
        $ResourceGroup = "RG_2"
        $Domain = "corp.contoso.com"

        $djoinaccount = Get-Credential

        $DomainINfo = @{
        "Name" =  "$Domain";
        "User" = $djoinaccount.Username;
        "Restart" =  "false";
        "Options" =  "3";
        "OUPath" = ""
        }
        $DomainINfo = $DomainINfo | ConvertTo-Json

        $Password = @{
        "Password" = $djoinaccount.GetNetworkCredential().password
        }
        $Password = $Password | ConvertTo-Json

    }
    Process
    {
        # Set BGInfo Extension
        Set-AzureRmVMExtension -ResourceGroupName $ResourceGroup -VMName "$VM" -ExtensionType "BGInfo" -Name "BGInfo" -Publisher "Microsoft.Compute" -TypeHandlerVersion "2.1" -Location $Location 
        # Join VM to domain
        Set-AzureRmVMExtension -ResourceGroupName $ResourceGroup -VMName "$VM" -ExtensionType "JsonADDomainExtension" -Name "joindomain" -Publisher "Microsoft.Compute" -TypeHandlerVersion "1.0" -Location $Location -SettingString $DomainINfo -ProtectedSettingString $Password

        # WinRM
        #https://github.com/Azure/azure-quickstart-templates/tree/3c9980dd6baf21e84e48fcc9028ee54b3c0269f6/201-vm-winrm-windows





    }
    End
    {

    }
}


