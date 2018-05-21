<#

Azure Log Analytics queries
# https://dev.loganalytics.io/
# https://docs.loganalytics.io/index
# https://dev.loganalytics.io/documentation/Tools/PowerShell-Cmdlets
# https://blogs.technet.microsoft.com/cbernier/2018/02/15/windows-update-compliance-querying-azure-log-analytics-data-using-powershell/

#>

$subscrID = "53fac23e-0234-4aa0-9097-0bd02896b7cf"
$WorkspaceName = "automation01oms"
$resourcegroupname = "rg_automation01"
$WorkspaceID = "197c29e4-5914-40e7-bea0-7a718679f5f7"

Import-Module -FullyQualifiedName "c:\dev\posh\Azure\LogAnalytics\LogAnalyticsQuery.psm1" -DisableNameChecking
<#
$query = "
SecurityBaseline
| where BaselineType in ('WindowsOS', 'Linux') and AnalyzeResult=='Failed'
| summarize Count=count() by BaselineRuleId, Description, RuleSeverity, AssessmentId, Computer
| order by Count desc
"
#>
$query = "SecurityEvent
| where TimeGenerated > ago(1d)
| summarize count() by tostring(EventID), AccountType, bin(TimeGenerated, 1h)"


$Result = Invoke-LogAnalyticsQuery -WorkspaceName $WorkspaceName -SubscriptionId $subscrID -ResourceGroup $resourcegroupname -Query $query -IncludeTabularView -IncludeStatistics

$Result.Results


