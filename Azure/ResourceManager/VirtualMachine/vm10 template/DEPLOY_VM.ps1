
$ResourceGroupName = "RG_2"

# Variables for Template and Template parameter file
$Templatefile = "C:\Data\dev\posh\Azure\ResourceManager\VirtualMachine\vm10 template\template.json"
$ParameterFile = "C:\Data\dev\posh\Azure\ResourceManager\VirtualMachine\vm10 template\parameters.json"


# Create Resource Group
#$ResourceGroupName = "RG_2" 
#$Location = "westeurope" 
#New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Verbose


Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile -Verbose
#New-AzureRmResourceGroupDeployment -Name "Deployvm_01"  -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile -Verbose
