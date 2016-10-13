
$ResourceGroupName = "RG_2"

$parameters = @{"location"="westeurope";
"virtualMachineName" = "VM11";
"virtualMachineSize" = "Basic_A2";
"adminUsername" = "Master_Admin";
"adminPassword" = "Access4theAdmin";
"storageAccountName" = "rg11099";
"virtualNetworkName" = "VNet1";
"networkInterfaceName" = "vm11558"
"networkSecurityGroupName" = "vm10-nsg";
#"diagnosticsStorageAccountName" = "rg11099"
#"diagnosticsStorageAccountId" = "/subscriptions/fac764d2-d579-41e0-ba9d-d787cf339faf/resourceGroups/rg_1/providers/Microsoft.Storage/storageAccounts/rg11099";
"subnetName" = "Subnet-1";
"publicIpAddressName" = "vm11-ip";
"publicIpAddressType" = "Dynamic";
}

$Templatefile = "C:\Data\dev\posh\Azure\ResourceManager\VirtualMachine\vm10 template\template.json"
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterObject $parameters -Verbose

New-AzureRmResourceGroupDeployment -Name "Deployvm02"  -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterObject $parameters -Verbose

