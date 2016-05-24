
$string1 = '{
"Name":  "corp.contoso.com",
"User": "corp.contoso.com\\Admin",
"Restart":  "true",
"Options":  "3",
"OUPath": ""
}'
$string2 = '{"Password": "password"}'

Set-AzureRmVMExtension -ResourceGroupName "RG_2" -ExtensionType "JsonADDomainExtension" -Name "joindomain" -Publisher "Microsoft.Compute" -TypeHandlerVersion "1.0" -VMName "vm73" -Location "westeurope" -SettingString $string1 -ProtectedSettingString $string2
