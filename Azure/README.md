# My Azure Scripts
Here's were I keep my Azure scripts. 



#Resource Manager
This folder contains scripts and templates to deploy resources using Azure Resource Manager

# Utilities
## Get-AzureImageSkuInfo.ps1
The Get-AzureImageSkuInfo cmdlet retrieves all image SKUs available and n the offers from all publishers.

Use this function to identify the parameter values required for the
Set-AzureRmVMSourceImage cmdlet that is used when creating new Azure VMs
using New-AzureRmVM.

## Get-AzureBlobInfo.ps1
Get-AzureBlobInfo lists all blob content stored witin all or the specified
storage account. 

## Cleanup-AzureRmPublicIPAddress.ps1
 Use the Cleanup-AzureRmPublicIPAddress to remove Azure Public IP Addresses that
 are not linked to an existing Azure VirtualMachine based on the IPConfiguration
 data being empty.

## Cleanup-AzureRmNetworkInterfaces.ps1
Use the Cleanup-AzureRmNetworkInterfaces to remove Azure Network Interfaces that
are not linked to an existing Azure VirtualMachine. 

##Cleanup-RmNetworkSecurityGroup.ps1
Use the Cleanup-AzureRmSecurityGroup to remove Azure Network Security Groups that are not
associated with any Subnet or Network interface being empty.

# Other sources
Manage Azure Virtual Machines using Resource Manager and PowerShell
https://azure.microsoft.com/en-gb/documentation/articles/virtual-machines-windows-ps-manage/


