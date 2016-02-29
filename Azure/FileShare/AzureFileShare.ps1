
# Azure File Share Stuff

#http://blogs.msdn.com/b/windowsazurestorage/archive/2014/05/12/introducing-microsoft-azure-file-service.aspx


$ResourceGroupName = "RG_2"
$StorageAccountName = "sazureverboon01"
$AccessKey = (Get-AzureRmStorageAccountKey -Name $StorageAccountName -ResourceGroupName $ResourceGroupName).Key1

# create a context for account and key
$ctx=New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $AccessKey


# create a new share
$s = New-AzureStorageShare myscripts -Context $ctx
  
 # create a directory in the test share just created
 New-AzureStorageDirectory -Share $s -Path testdir

# upload a local file to the testdir directory just created
Set-AzureStorageFileContent -Share $s -Source C:\Data\dev\posh\LICENSE -Path testdir

# list out the files and subdirectories in a directory
Get-AzureStorageFile -Share $s -Path testdir 

# download files from azure storage file service
 Get-AzureStorageFileContent -Share $s -Path testdir/license -Destination c:\temp
  
 # remove files from azure storage file service
 Remove-AzureStorageFile -Share $s -Path testdir/license



 $file1 = "https://sazureverboon01.file.core.windows.net/vmscripts/runme1.ps1"
$vmid =  ( Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name vm00111).Id

Set-AzureRmVMCustomScriptExtension -Name "RunMe" -FileUri $file1 -VMName vm00111 -Run "runme1.ps1" -ResourceGroupName $ResourceGroupName -Location "westeurope"



