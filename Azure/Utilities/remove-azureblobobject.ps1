



 $ctx = New-AzureStorageContext -StorageAccountName rg11099 -StorageAccountKey 5DKl43OshxXet898l1tjvbk8YFYnnbRuIjyDQlziBLfiFXbpg10JdL8/twDdapOVK2F5+dNfcHWMHcDFxGD/3w==

# ($b.StorageAccountKey)[0].Value
 Remove-AzureStorageBlob -Blob vm12201692105728.vhd -Container vhds -Context $ctx

 #Remove-AzureStorageContainer bootdiagnostics-vm1-e3c7d72a-cc99-4946-8be7-9fd624feed68 -Context $ctx
