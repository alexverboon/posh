
Function Get-AzureBlobInfo
{
<#
.Synopsis
   Get-AzureBlobInfo lists all blob content stored in Azure
.DESCRIPTION
   Get-AzureBlobInfo lists all blob content stored witin all or the specified
   storage account. 
.EXAMPLE
   Get-AzureBlobInfo

   List all storage blobs stored within all available storage accounts

.EXAMPLE
  Get-AzureBlobInfo -StorageAccountName rg2disks444

  List all storage blobs stored wtihin the storage account rg2disks444

EXAMPLE
  Get-AzureBlobInfo | Select-Object Name,STorageaccount,LeaseStatus

  List all storage blobs and output the lease status

.EXAMPLE
  Get-AzureBlobInfo | Where-Object {($_.name).split(".")[-1] -like "vhd" }

  List all vhd files


#>
[CmdletBinding()]
Param(
        # Name of the Storage Account
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $StorageAccountName
)

Begin{

    If ($PSBoundParameters.ContainsKey("StorageAccountName"))
    {
        Write-Verbose "StorageAccount provided: $($StorageAccountName)"
        $storageaccounts = Get-AzureRmStorageAccount | Where-Object {$_.StorageAccountName -like "$StorageAccountName"}

        If ($storageaccounts -eq $null)
        {
            Write-Error "invalid Storage account: $($StorageAccountName)"
        }
    }
    Else
    {
        $storageaccounts = Get-AzureRmStorageAccount 
    }
}

Process{

$blobinfo = @()

ForEach ($sa in $storageaccounts)
{

   $StorageKey = Get-AzureRmStorageAccountKey -ResourceGroupName $sa.ResourceGroupName -Name $sa.StorageAccountName 
   $containers =  $sa | Get-AzureStorageContainer 

   ForEach ($cont in $containers)
   {
        $blobcontent = $cont  |  Get-AzureStorageBlob 
        If ($blobcontent -eq $null)
        {
            write-verbose "Container: $($cont.name) has no blob content"
        }
           ForEach ($blob in $blobcontent)
           {
                $object = New-Object -TypeName PSObject
                # StorageAccount Info
                $object | Add-Member -MemberType NoteProperty -Name StorageAccount -Value $($sa.StorageAccountName)
                $object | Add-Member -MemberType NoteProperty -Name Location -Value $($sa.Location)
                $object | Add-Member -MemberType NoteProperty -Name SKU -Value $($sa.Sku.Name)
                $object | Add-Member -MemberType NoteProperty -Name StorageAccountKey -Value $StorageKey
                # Container Info
                $object | Add-Member -MemberType NoteProperty -Name ContainerName -Value $($cont.Name)
                $object | Add-Member -MemberType NoteProperty -Name ContainerInfo -Value $($cont)
                #Blob info
                $object | Add-Member -MemberType NoteProperty -Name BlobType -Value $($blob.BlobType)
                $object | Add-Member -MemberType NoteProperty -Name ICloudBlob -Value $($blob.ICloudBlob)       
                $object | Add-Member -MemberType NoteProperty -Name Name -Value $($blob.Name)       
                $object | Add-Member -MemberType NoteProperty -Name LeaseStatus -Value $($blob.ICloudBlob.Properties.LeaseStatus)  
                $object | Add-Member -MemberType NoteProperty -Name LeaseState -Value $($blob.ICloudBlob.Properties.LeaseState)  
                $object | Add-Member -MemberType NoteProperty -Name Properties -Value $($blob.ICloudBlob.Properties) 
                $object | Add-Member -MemberType NoteProperty -Name LastModified -Value $($blob.LastModified) 
                $blobinfo += $object
           }
        }
}
}

End{
    $blobinfo
}
}


# $ctx = New-AzureStorageContext -StorageAccountName rg11099 -StorageAccountKey ($b.StorageAccountKey)[0].Value
 #Remove-AzureStorageBlob -Blob vm1.e3c7d72a-cc99-4946-8be7-9fd624feed68.screenshot.bmp -Container bootdiagnostics-vm1-e3c7d72a-cc99-4946-8be7-9fd624feed68  -Context $ctx

 #Remove-AzureStorageContainer bootdiagnostics-vm1-e3c7d72a-cc99-4946-8be7-9fd624feed68 -Context $ctx
