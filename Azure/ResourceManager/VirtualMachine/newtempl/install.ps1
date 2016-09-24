
$ResourceGroupName = "RG_2" 
$Location = "westeurope" 
$TemplateFile = "C:\Data\dev\posh\Azure\ResourceManager\VirtualMachine\newtempl\template.json"
$ParameterFile = "C:\Data\dev\posh\Azure\ResourceManager\VirtualMachine\newtempl\parameters.json"


#Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterUri $ParameterFile -Verbose
#New-AzureRmResourceGroupDeployment -Name "Deployvm_02"  -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterUri $ParameterFile -Verbose
New-AzureRmResourceGroupDeployment -Name "Deployvm_O3" -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile -Verbose


