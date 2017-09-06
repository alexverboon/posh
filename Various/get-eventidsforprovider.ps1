
# list all possible event IDs for an event provider
# https://blogs.technet.microsoft.com/pie/2016/11/05/list-all-possible-security-events-and-their-descriptions-in-powershell/
# https://blogs.technet.microsoft.com/ashleymcglone/2013/08/28/powershell-get-winevent-xml-madness-getting-details-from-event-logs/



(Get-WinEvent -ListProvider "Microsoft-Windows-PowerShell").Events | `
    Select-Object @{Name='Id';Expression={$_.Id -band 0xffffff}}, Description, @{Name='Parameters';Expression={($_.Template).template.data}} | `
        Out-GridView -Title "Audit Event IDs" -PassThru | `
            Format-List


           
# List all event providers            
Get-WinEvent -ListProvider * | Format-Table            
            
# List all policy-related event providers.            
Get-WinEvent -ListProvider *policy* | Format-Table            
            
# List the logs on the machine where the name is like 'policy'            
Get-WinEvent -ListLog *policy*            
            
# List all possible event IDs and descriptions for the provider            
(Get-WinEvent -ListProvider Microsoft-Windows-GroupPolicy).Events |            
   Format-Table id, description -AutoSize            
            
# List all of the event log entries for the provider            
Get-WinEvent -LogName Microsoft-Windows-GroupPolicy/Operational            
            
# Each event in each provider has its own message data schema.            
# Use this line to find the of each event ID.            
# For a specific event            
(Get-WinEvent -ListProvider Microsoft-Windows-PowerShell).Events |
   Where-Object {$_.Id -eq 4103}
            
# For a keyword in the event data            
(Get-WinEvent -ListProvider Microsoft-Windows-GroupPolicy).Events |            
   Where-Object {$_.Template -like "*reason*"}            
            
# Find an event ID across all ETW providers:            
Get-WinEvent -ListProvider * |            
   ForEach-Object { $_.Events | Where-Object {$_.ID -eq 4168} }     