
function Cleanup-AzureRmNetworkInterfaces
{
<#
.Synopsis
   Cleanup-AzureRmNetworkInterfaces removes Network Interfaces that are not linked
   to an Azure VirtualMachine
.DESCRIPTION
   Use the Cleanup-AzureRmNetworkInterfaces to remove Azure Network Interfaces that 
   are not linked to an existing Azure VirtualMachine. 
.PARAMETER ResourceGrup
   Specifies the name of the resource group from which network interfaces are
   to be retrieved.
.PARAMETER ListOnly
  Only lists Azure Network Interfaces that are not linked to an existing Azure Virtual Machine

.EXAMPLE
   Cleanup-AzureRmNetworkInterfaces -ResourceGroup RG_2
.EXAMPLE
   Cleanup-AzureRmNetworkInterfaces -ResourceGroup RG_2 -ListOnly

   Name   ResourceGuid                        
   ----   ------------                        
   vm3872 7d17b843-e9fb-4838-bce5-428817a95037
.NOTES
    Alex Verboon, version 1.0, 01.10.2016
#>

   [CmdletBinding(SupportsShouldProcess=$true,
   ConfirmImpact="High")]
    Param
    (
        # Specifies the name of the resource group from which network interfaces are to be retrieved.
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
            $az_networkinterfaces = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroup
            $RemAzNetworkInterface = $az_networkinterfaces |  Where-Object {$_.VirtualMachine -eq $null}
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
            $RemAzNetworkInterface | Select-Object Name,ResourceGuid
        }
        Else
        {
            ForEach($ni in $RemAzNetworkInterface)
            {
                if ($pscmdlet.ShouldProcess("Deleting NetworkInterface $($ni.Name)"))
                {
                   Write-Output "Removing NetworkInterface without Virtual Machine association: $($ni.Name)"
                   Remove-AzureRmNetworkInterface -Name "$($ni.name)" -ResourceGroupName $ResourceGroup 
                   $object = New-Object -TypeName PSObject
                   $object | Add-Member -MemberType NoteProperty -Name Name -Value $($ni.Name)
                   $object | Add-Member -MemberType NoteProperty -Name ResourceGuid -Value $($ni.ResourceGuid)
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



