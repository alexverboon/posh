
# https://docs.microsoft.com/en-us/rest/api/storageservices/querying-tables-and-entities
# https://blog.tyang.org/2016/11/30/powershell-module-for-managing-azure-table-storage-entities/
# https://www.powershellgallery.com/packages/AzureTableEntity/1.0.0.0
# https://github.com/tyconsulting/AzureTableEntity-PowerShell-Module
# https://docs.microsoft.com/en-us/rest/api/storageservices/designing-a-scalable-partitioning-strategy-for-azure-table-storage


$subscriptionName = "MSDN Platforms"

# Create ResourceGroup
$Location = "Westeurope"
$ComputerInventory_ResourceGroup = "rg_CompComputerInventory"
New-AzureRmResourceGroup -Name $ComputerInventory_ResourceGroup -Location $Location 

# Create StorageAccount
$SkuName = "Standard_LRS"
$ComputerInventory_StorageAccountName = "sacomputerinventory"
New-AzureRmStorageAccount -ResourceGroupName $ComputerInventory_ResourceGroup -Name $ComputerInventory_StorageAccountName -SkuName "$SkuName" -Location $Location

# Retrieve the first StorageAccountAccessKey
$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ComputerInventory_ResourceGroup -Name $ComputerInventory_StorageAccountName
$StorageAccountAccessKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ComputerInventory_ResourceGroup -Name $ComputerInventory_StorageAccountName).Value[0]

#Create Table
$TableName = "ComputerInventory"
$context = New-AzureStorageContext -StorageAccountName $ComputerInventory_StorageAccountName -StorageAccountKey $StorageAccountAccessKey
New-AzureStorageTable -Name $TableName -Context $context


# Add one entry
    $data = @{
    RowKey = ([guid]::NewGuid().tostring())
    PartitionKey = "Inventory"
    ComputerName = "Computer000001"
    Location = "Amsterdam"
    dtDate = [datetime]::UtcNow
    }

New-AzureTableEntity -StorageAccountName $ComputerInventory_StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Verbose -Entities $data

# Generate some demo data for PC inventory

    $locations = @("Amsterdam","Paris","Stockholm","London","New York","Seatle","Singapure","Hong Kong","The Hague","Barcelona","Madrid","Stockholm","Rome")
    $data = @()
    $count = 2
     While ($count -le 100)
     {
        $obj = @{
            RowKey = ([guid]::NewGuid().tostring())
            PartitionKey = "Inventory"
            ComputerName = "Computer" + $count.ToString("000000")
            Location = ($locations)[(Get-Random -Minimum 0 -Maximum $locations.Count )]
            dtDate = [datetime]::UtcNow
        }
        $data += (New-Object -TypeName PSCustomObject -Property $obj)
        $count++
    }


# Add rows to Azure Storage Table
New-AzureTableEntity -StorageAccountName $ComputerInventory_StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Verbose -Entities $data

# Retrieve Table Data
$querystring = "(PartitionKey eq 'Inventory')"
$result = Get-AzureTableEntity -TableName $tableName -StorageAccountName $ComputerInventory_StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey  -QueryString $querystring -ConvertDateTimeFields $true -GetAll $true -Verbose
$result.Count
$result | Group-Object Location


# only computer1
$querystring = "(ComputerName eq 'Computer000001')"
$result = Get-AzureTableEntity -TableName $tableName -StorageAccountName $ComputerInventory_StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey  -QueryString $querystring -ConvertDateTimeFields $true -GetAll $true -Verbose
$result

$NewLoczation = "Rotterdam"

$data = @{
PartitionKey = $result.PartitionKey
RowKey       = $result.RowKey
Location = $NewLoczation
ComputerName = $result.ComputerName
dtDate = $result.dtDate
}

Update-AzureTableEntity -StorageAccountName $ComputerInventory_StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Entities $data
$querystring = "(ComputerName eq 'Computer000001')"
$result = Get-AzureTableEntity -TableName $tableName -StorageAccountName $ComputerInventory_StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey  -QueryString $querystring -ConvertDateTimeFields $true -GetAll $true -Verbose
$result



$Remove = @{
PartitionKey = $result.PartitionKey
RowKey = $result.RowKey
Computername = $result.ComputerName
}

Remove-AzureTableEntity -StorageAccountName $ComputerInventory_StorageAccountName -StorageAccountAccessKey $StorageAccountAccessKey -TableName $TableName -Entities $Remove

