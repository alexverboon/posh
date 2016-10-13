
$ResourceGroup = "RG_3"
$Running = Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroup | Where-Object {$_.ProvisioningState -inotlike "Succeeded"}

#$sel = $Running | Select-Object DeploymentName | Out-GridView -OutputMode Single
#$sel.DeploymentName


$operations = Get-AzureRmResourceGroupDeploymentOperation –DeploymentName $Deploymentname –ResourceGroupName $ResourceGroup 

foreach($operation in $operations)

{
    Write-Host $operation.id
    Write-Host "Request:"
    $operation.Properties.Request | ConvertTo-Json -Depth 10
    Write-Host "Response:"
    $operation.Properties.Response | ConvertTo-Json -Depth 10
}

