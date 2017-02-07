
function Get-AzureRmVMSizeSpecs
{
<#
.Synopsis
   Get-AzureRmVMSizeSpecs
.DESCRIPTION
   Get-AzureRmVMSizeSpecs
.PARAMETER Location
Specifies the location for which this cmdlet gets the available virtual machine sizes

.PARAMETER ResourceGroupName
Specifies the name of a resource group.

.EXAMPLE
   Get-AzureRmVMSizeSpecs -Location westeurope

   This command gets all available virtual machine sizes in the specified location

.EXAMPLE
  Get-AzureRmVMSizeSpecs -Location westeurope | Where-Object {$_.NumberofCores -eq 2}
  
  This command gets all available virtual machine sizes where NumberofCores is 2

.EXAMPLE
   Get-AzureRmVMSizeSpecs -ResourceGroupName RG_2 

Name                 : VM-001
HardwareProfile      : Standard_D2_v2
Location             : westeurope
NumberofCores        : 2
MemoryInMB           : 7168
MaxDataDiskCount     : 4
OSDiskSizeInMB       : 1047552
ResourceDiskSizeInMB : 102400

Name                 : DC1
HardwareProfile      : Basic_A2
Location             : westeurope
NumberofCores        : 2
MemoryInMB           : 3584
MaxDataDiskCount     : 4
OSDiskSizeInMB       : 1047552
ResourceDiskSizeInMB : 61440

   This command gets the VM size confirmation details for all virtual machines deployed within
   the specified ResourceGroup

.EXAMPLE
 ForEach ($rg in Get-AzureRmResourceGroup) {Get-AzureRmVMSizeSpecs -ResourceGroupName $rg.ResourceGroupName -Verbose}
 
 Lists all the VM size information within each resource group that has virtual machine resources
 

.NOTES
    alex verboon, version 1.0, 07/2017

#>
[CmdLetBinding()]
    Param
    (
        # Specifies the location for which this cmdlet gets the available virtual machine sizes
        [Parameter(ParameterSetName = "Location",
                   Mandatory=$true,
                   ValueFromPipelineByPropertyName=$false,
                   Position=0)]
        [validateset("australiaeast","australiasoutheast","brazilsouth","canadacentral",
        "canadaeast","centralus","eastasia","eastus","eastus2","japaneast","japanwest","northcentralus",
        "northeurope","southcentralus","southeastasia","uksouth","ukwest","westcentralus",
        "westeurope","westus","westus2")]
                $Location, 

        # Specifies the name of a resource group.
        [Parameter(ParameterSetName = "ResourceGroup",
                   Mandatory=$true,
                   ValueFromPipelineByPropertyName=$false,
                   Position=0)]
        $ResourceGroupName
    )

    Begin
    {
        Try{
            $null = Get-AzureRmSubscription
        }
        Catch{
                $null = Login-AzureRmAccount
        }
    }
    Process
    {
        if ($PSBoundParameters.ContainsKey("Location"))
        {
            $Results = Get-AzureRmVMSize -Location $Location
        }

        if ($PSBoundParameters.ContainsKey("ResourceGroupName"))
        {
            $vminfo = Get-AzureRmVM -ResourceGroupName $ResourceGroupName
            If ($($vminfo).count -gt 0) 
            {
                ForEach ($vmi in $vminfo)
                {
                    $sizeinfo = Get-AzureRmVMSize -Location $vmi.location | where-object {$_.name -eq "$($vmi.hardwareprofile.vmsize)"}
                    $props = [ordered]@{
                    "Name" = $vmi.name
                    "HardwareProfile" = $vmi.hardwareprofile.vmsize
                    "Location" = $vmi.location
                    "NumberofCores" = $sizeinfo.NumberOfCores
                    "MemoryInMB" = $sizeinfo.MemoryinMB
                    "MaxDataDiskCount" = $sizeinfo.MaxDataDiskCount
                    "OSDiskSizeInMB" = $sizeinfo.OSDiskSizeInMB
                    "ResourceDiskSizeInMB" = $sizeinfo.ResourceDiskSizeInMB
                    }
                $Results += @(New-Object pscustomobject -Property $props)
                }
            }
            Else
            {
                Write-Verbose "ResourceGroup: $ResourceGroupName does not contain virtual machine resources"
            }
        }
    }
    End
    {
        Write-Output $Results
    }
}
