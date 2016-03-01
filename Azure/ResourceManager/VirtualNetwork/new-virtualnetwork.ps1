

# Login to Azure
#Login-AzureRmAccount

# Variables for Template and Template parameter file
$TemplateFile =  'azuredeploy_virtualnetwork.json'
$ParameterFile = 'azuredeploy_virtualnetwork.parameters.json'
$TemplateFile = [System.IO.Path]::Combine($PSScriptRoot, $TemplateFile)
$ParameterFile = [System.IO.Path]::Combine($PSScriptRoot, $ParameterFile)

# Input Object
$paramobj = @{ vnetname = "Vnet22"}






#New-AzureRmResourceGroupDeployment -Name "myvnetwork1" -ResourceGroupName "RG_2" -TemplateFile D:\DEV\azuredeploy.json -TemplateParameterFile D:\DEV\azuredeploy.parameters



#New-AzureRmResourceGroupDeployment -Name "myvnetwork1" -ResourceGroupName "RG_2" -TemplateFile D:\DEV\azuredeploy.json -TemplateParameterObject $obj

#New-AzureRmResourceGroupDeployment -Name "myvnetwork1" -ResourceGroupName "RG_2" -TemplateFile D:\DEV\azuredeploy.json -vnetName 

