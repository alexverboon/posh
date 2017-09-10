

$pslogs = Get-WinEvent  -FilterHashtable @{ ProviderName="Microsoft-Windows-PowerShell"; Id = 4103,4104,4105,4106 } 

#$a = Get-WinEvent  -FilterHashtable @{ ProviderName="Microsoft-Windows-PowerShell"; Id = 4103 } 
$b = Get-WinEvent  -FilterHashtable @{ ProviderName="Microsoft-Windows-PowerShell"; Id = 4104 } 
#$c = Get-WinEvent  -FilterHashtable @{ ProviderName="Microsoft-Windows-PowerShell"; Id = 4105 } 
$d = Get-WinEvent  -FilterHashtable @{ ProviderName="Microsoft-Windows-PowerShell"; Id = 4106 }
 
$pslogs |Select-Object * | sort-Object ActivityID | fl
