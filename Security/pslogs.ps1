# Module Logging
$PSModuleLogs = @{ProviderName = "Microsoft-Windows-PowerShell";ID=4100,4103}
$s= Get-WinEvent -FilterHashtable $PSModuleLogs -MaxEvents 50 
 
# Script Block logging
$PSScriptBlocklogs = @{ProviderName = "Microsoft-Windows-PowerShell";ID=4104,4105,4106}
$x = Get-WinEvent -FilterHashtable $PSScriptBlocklogs -MaxEvents 50 

# all
$PSLogs = @{ProviderName = "Microsoft-Windows-PowerShell";ID=4100,4103,4104,4105,4106,24579,24577}
$logs = Get-WinEvent -FilterHashtable $PSLogs -MaxEvents 100 





