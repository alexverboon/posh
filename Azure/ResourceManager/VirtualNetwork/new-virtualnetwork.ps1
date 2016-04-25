


# Login to Azure
        Try{
            $checkifconnected =Get-AzureRmVMImagePublisher -Location $location 
        }
        Catch{
            # okay looks liek we're not yet connected
            Login-AzureRmAccount
            $checkifconnected =Get-AzureRmVMImagePublisher -Location $location  
        }


# Variables for Template and Template parameter file
$Templatefile = "https://raw.githubusercontent.com/alexverboon/posh/master/Azure/ResourceManager/VirtualNetwork/azuredeploy_virtualnetwork.json"
$ParameterFile = "https://raw.githubusercontent.com/alexverboon/posh/master/Azure/ResourceManager/VirtualNetwork/azuredeploy_virtualnetwork.parameters.json"

# Input Object
$paramobj = @{ vnetname = "Vnet3"}

# Create Resource Group
$ResourceGroupName = "TestResourceGroup" 
$Location = "westeurope" 
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Verbose



# Let's test things first

#Test with Template only
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -Verbose
#Test with Template and parameter file
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterUri $ParameterFile -Verbose
#Test with template and parameter object
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterObject $paramobj -Verbose
 

#and now create virtual networks
New-AzureRmResourceGroupDeployment -Name "Example1"  -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -Verbose -Mode Complete
New-AzureRmResourceGroupDeployment -Name "Example2"  -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterUri $ParameterFile -Verbose
New-AzureRmResourceGroupDeployment -Name "Example3"  -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterObject $paramobj -Verbose 

# let's look at the Deployments
Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName 

# now with complete mode
New-AzureRmResourceGroupDeployment -Name "Example3"  -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateFile -TemplateParameterObject $paramobj -Mode Complete -Verbose
