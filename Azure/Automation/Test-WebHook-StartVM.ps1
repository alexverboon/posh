<#
.Synopsis
   Test-WebHook-StartVM
.DESCRIPTION
   Test-WebHook-StartVM triggers the webhook for Test-StartVirtualMachinesFromWebhook
#>


# Web hook, start Azue VM
$uri = "https://s2events.azure-automation.net/webhooks?token=FjN6C4OOD2d7T%2fAKhUfnZajjEzBM8YFUNshf1wEO%2bt4%3d"
$headers = @{"From"="alex@contoso.com";"Date"="02/9/2017 16:47:00"}

$vms  = @(
            @{ Name="win10vm2";ResourceGroupName="RG_win10vm02"}
        )
$body = ConvertTo-Json -InputObject $vms

$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
$job = $response.JobIds

