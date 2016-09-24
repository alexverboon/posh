#http://www.techdiction.com/2016/02/12/create-a-custom-script-extension-for-an-azure-resource-manager-vm-using-powershell/

$rgname = "rg_vm"
$VMName = "vm4"
$file = "C:\Data\dev\posh\Azure\Utilities\ConfigureWinRM_HTTPS.ps1"
$containerName = "script-container"

# Get the VM we need to configure
$vm = Get-AzureRmVM -ResourceGroupName $rgname -Name $VMName
 
# Get storage account name
$storageaccountname = $vm.StorageProfile.OsDisk.Vhd.Uri.Split('.')[0].Replace('https://','')
 
# get storage account key
$key = (Get-AzureRmStorageAccountKey -Name $storageaccountname -ResourceGroupName $rgname).Key1
 
# create storage context
$storagecontext = New-AzureStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $key
 
# create a container called scripts
New-AzureStorageContainer -Name "scripts" -Context $storagecontext
 
#upload the file
Set-AzureStorageBlobContent -Container "scripts" -File "$file" -Context $storagecontext -Blob "ConfigureWinRM_HTTPS.ps1" -BlobType Page 




# Create custom script extension from uploaded file
#Set-AzureRmVMCustomScriptExtension -ResourceGroupName $rgname -VMName $vmname -Name "EnableWinRM_HTTPS" -Location $vm.Location -StorageAccountName $storageaccountname -StorageAccountKey $key -FileName "ConfigureWinRM_HTTPS.ps1" -ContainerName "scripts"
