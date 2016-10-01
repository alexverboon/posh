
function Cleanup-AzureRmPublicIPAddress
{
<#
.Synopsis
   Cleanup-AzureRmPublicIPAddress removes Public IP Addresses that are not linked
   to an Azure VirtualMachine
.DESCRIPTION
   Use the Cleanup-AzureRmPublicIPAddress to remove Azure Public IP Addresses that 
   are not linked to an existing Azure VirtualMachine based on the IPConfiguration data
   being empty.
.PARAMETER ResourceGrup
   Specifies the name of the resource group from which Public IP Addresses are
   to be retrieved.
.PARAMETER ListOnly
  Only lists Azure Public IP Addresses that are not linked to an existing Azure Virtual Machine

.EXAMPLE
   Cleanup-AzureRmPublicIPAddress -ResourceGroup RG_2
.EXAMPLE
   Cleanup-AzureRmPublicIPAddress -ResourceGroup RG_2 -ListOnly

   Lists all Public IP Addresses that have no association to a virtual machine.

    Name    ResourceGuid                        
    ----    ------------                        
    vm01-ip b5c0f73b-abda-4a24-b3bd-2722b08aabe0
    VM2-ip  f03360f2-887e-44fe-a5ad-396195cd8efc
    VM3-ip  5db8d1fa-f551-4794-a9c0-27cd005b4742
.NOTES
    Alex Verboon, version 1.0, 01.10.2016
#>

   [CmdletBinding(SupportsShouldProcess=$true,
   ConfirmImpact="High")]
    Param
    (
        # Specifies the name of the resource group from which Public IP Addresses are to be retrieved.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$ResourceGroup,
        # Only lists Azure Network Interfaces that are not linked to an existing Azure Virtual Machine
        [switch]$ListOnly
    )
    Begin
    {
        If (AzureRmResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue )
        {        
            $az_publicipaddress = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup
            $RemAzPublicIP = $az_publicipaddress |  Where-Object {$_.IpConfiguration -eq $null}
        }
        Else
        {
            Write-Error "Provided resource group does not exist: $ResourceGroup"
            Throw
        }
    }
    Process
    {
        $removed = @()
        If ($PSBoundParameters.ContainsKey("ListOnly"))
        {
            $RemAzPublicIP | Select-Object Name,ResourceGuid
        }
        Else
        {
            ForEach($pi in $RemAzPublicIP)
            {
                if ($pscmdlet.ShouldProcess("Deleting NetworkInterface $($pi.Name)"))
                {
                   Write-Output "Removing Public IP Address without Virtual Machine association: $($pi.Name)"
                   Remove-AzureRmPublicIpAddress -Name "$($pi.name)" -ResourceGroupName $ResourceGroup 
                   $object = New-Object -TypeName PSObject
                   $object | Add-Member -MemberType NoteProperty -Name Name -Value $($pi.Name)
                   $object | Add-Member -MemberType NoteProperty -Name ResourceGuid -Value $($pi.ResourceGuid)
                   $removed += $object
                }
            }
        }
    }
    End
    {
        # List the removed objects
        $removed 
    }
}



