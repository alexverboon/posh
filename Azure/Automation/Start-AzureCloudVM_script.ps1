
<#
.Synopsis
   Start-AzureCloudVM 
.DESCRIPTION
   Start-AzureClouodVM starts an Azure VM
.EXAMPLE
  Start-AzureCloudVM -Name win10vm2 -ResourceGroupName RG_win10vm02
#>
    Param
    (
        # Name of the Virtual Machine
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Name,

        # Azure ResourceGroup Name
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
        $ResourceGroupName
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



        Write-verbose "Starting VM $Name in ResourceGroup: $ResourceGroupName"
        Start-AzureRmVM -Name $Name -ResourceGroupName $ResourceGroupName 

        