## 
## Use the below commands to install the PowerSploit module
##

# add an exclusion path for defender, otherwise files will be removed as they look like malware
# well, in fact they could be right :-)
Set-MpPreference -ExclusionPath "C:\Program Files\WindowsPowerShell\Modules\PowerSploit\"
# Disable defender
Set-MpPreference -DisableRealtimeMonitoring $true
# check the exclusionpath , should include the path set previously
Get-MpPreference | Select-Object -ExpandProperty Exclusionpath
# install the powersploit package
find-package powersploit | Install-Package
# Turn on defender again
Set-MpPreference -DisableRealtimeMonitoring $false

