<#
.Synopsis
   Test-StartVirtualMachinesFromWebhook
.DESCRIPTION
   Test-StartVirtualMachinesFromWebhook is called via a webook and stops the 
   specified VMs
#>
workflow Test-StartVirtualMachinesFromWebhook
{
    param (
        [object]$WebhookData
    )

    # If runbook was called from Webhook, WebhookData will not be null.
    if ($WebhookData -ne $null) {

        # Collect properties of WebhookData
        $WebhookName     =     $WebhookData.WebhookName
        $WebhookHeaders =     $WebhookData.RequestHeader
        $WebhookBody     =     $WebhookData.RequestBody

        # Collect individual headers. VMList converted from JSON.
        $From = $WebhookHeaders.From
        $VMList = ConvertFrom-Json -InputObject $WebhookBody
        Write-Output "Runbook started from webhook $WebhookName by $From."

        # Authenticate to Azure resources
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

        # Start each virtual machine
        foreach ($VM in $VMList)
        {
            $VMName = $VM.Name
            Write-Output "Starting $VMName"
            Start-AzureRMVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
        }
    }
    else {
        Write-Error "Runbook mean to be started only from webhook."
    }
}
