
function Cleanup-RmNetworkSecurityGroup
{
<#
.Synopsis
   Cleanup-AzureRmSecurityGroup removes Azure Network Security Groups that are not associated with
   a Subnet or a Network interface
.DESCRIPTION
   Use the Cleanup-AzureRmSecurityGroup to remove Azure Network Security Groups that are not 
   associated with any Subnet or Network interface
   being empty.
.PARAMETER ResourceGrup
   Specifies the name of the resource group from which Public IP Addresses are
   to be retrieved.
.PARAMETER ListOnly
  Only lists Azure Network Security Groups that are not associated with a subnet or network interface

.EXAMPLE
   Cleanup-RmNetworkSecurityGroup -ResourceGroup RG_2

.EXAMPLE
   Cleanup-RmNetworkSecurityGroup -ResourceGroup RG_2 -ListOnly

   Lists all Azure Network Security Groups that are not associated with a subnet or network interface


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

            $az_nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroup
            $RemAzSecurityGroup = $az_nsg |  Select-Object Name, Subnets,Networkinterfaces | Where-Object {$_.subnets.id -eq $null -and $_.networkinterfaces.id -eq $null}
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
            $RemAzSecurityGroup | Select-Object Name
        }
        Else
        {
            ForEach($sg in $RemAzSecurityGroup)
            {
                if ($pscmdlet.ShouldProcess("Deleting NetworkInterface $($sg.Name)"))
                {
                   Write-Output "Removing Azurer Network Security Group: $($sg.Name)"
                   Remove-AzureRmNetworkSecurityGroup -Name "$($sg.name)" -ResourceGroupName $ResourceGroup 
                   $object = New-Object -TypeName PSObject
                   $object | Add-Member -MemberType NoteProperty -Name Name -Value $($sg.Name)
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





