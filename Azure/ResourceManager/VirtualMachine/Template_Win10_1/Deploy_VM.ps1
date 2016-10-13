
$ResourceGroupName = "RG_3"

#New-AzureRmResourceGroup -Name $ResourceGroupName -Location "westeurope" -Tag @{Company="FooCorp"}


$vmname = "vm14"
$Templatefile = "C:\Data\dev\posh\Azure\ResourceManager\VirtualMachine\Template_Win10_1\template.json"


$parameters = @{"location"="westeurope";
"virtualMachineName" = "$vmname";
"virtualMachineSize" = "Basic_A2";
"adminUsername" = "Master_Admin";
"adminPassword" = "Access4theAdmin";
"storageAccountName" = "rg11099";
"virtualNetworkName" = "VNet1";
"networkInterfaceName" = "ni_$vmname"
"networkSecurityGroupName" = "$vmname-nsg";
"subnetName" = "Subnet-1";
"publicIpAddressName" = "$vmname-ip";
"publicIpAddressType" = "Dynamic";
}


$TestTempl = Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterObject $parameters -Verbose

New-AzureRmResourceGroupDeployment -Name "Deployvm$vmname"  -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterObject $parameters -Verbose -DeploymentDebugLogLevel All


