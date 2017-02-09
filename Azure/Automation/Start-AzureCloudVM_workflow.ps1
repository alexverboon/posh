

<#
.Synopsis
   Workflow Start-AzureCloudVM 
.DESCRIPTION
   Workflow Start-AzureClouodVM starts an Azure VM
.EXAMPLE
  Start-AzureCloudVM -Name win10vm2 -ResourceGroupName RG_win10vm02
#>

Workflow Start-AzureCloudVM
{
    Param
    (
        # Name of the Virtual Machine
        [string]$Name,
        # Azure ResourceGroup Name
        [string]$ResourceGroupName
    )


    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }


    Write-Verbose "Starting VM $Name in ResourceGroup $ResourceGroupName"
    Start-AzureRmVM -Name $Name -ResourceGroupName $ResourceGroupName

}