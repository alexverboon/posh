

# check wdatp config, event logs etc. 
Get-WinEvent -ProviderName "WDATPOnboarding"
Get-WinEvent -Providername "Microsoft-Windows-Sense"
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection"
Get-Service -Name DiagTrack 
Get-Service -Name Sense
