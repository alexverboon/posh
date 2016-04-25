

# Variables for Template and Template parameter file
$Templatefile = "https://raw.githubusercontent.com/alexverboon/posh/master/Azure/ResourceManager/VirtualMachine/WindowsVirtualMachine.json"
$ParameterFile = "https://raw.githubusercontent.com/alexverboon/posh/master/Azure/ResourceManager/VirtualMachine/WindowsVirtualMachine.parameters.json"

# Create Resource Group
$ResourceGroupName = "RG_2" 
$Location = "westeurope" 
#New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Verbose

#Test with Template and parameter file
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterUri $ParameterFile -Verbose
New-AzureRmResourceGroupDeployment -Name "Deployvm_01"  -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterUri $ParameterFile -Verbose





