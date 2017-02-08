# This script contains some examples how to retrieve Windows Upgrade Analytics data
# that is stored in OMS

# I used the guidance provided here:
# https://blogs.technet.microsoft.com/privatecloud/2016/04/05/using-the-oms-search-api-with-native-powershell-cmdlets/

# Module Installation instructions, if not installed yet.
# Install OMS PowerShell Module
# Find-Module AzureRM.OperationalInsights | Install-Module
# Install-Module AzureRM.OperationalInsights -Scope AllUsers
# Get-Module AzureRm.OperationalInsights 

# Find OMS Workspaces
Find-AzureRmResource -ResourceType "Microsoft.OperationalInsights/workspaces"

#$ResourceGroupName = "mms-weu"
#$WorkSpaceName = "AlexVerboonOMS" 

$ResourceGroupName = "RG-OMSWorkplace"
$WorkSpaceName = "OMSWorkplace" 

# Get Saved Searches 
$query = Get-AzureRmOperationalInsightsSavedSearch `
 -ResourceGroupName $ResourceGroupName `
 -WorkspaceName $WorkSpaceName
$query.value |FL

$query = Get-AzureRmOperationalInsightsSavedSearch `
 -ResourceGroupName $ResourceGroupName `
 -WorkspaceName $WorkSpaceName `
 -SavedSearchId "test|Drivers"
$query.properties | FL

# saved search 1
$result = Get-AzureRmOperationalInsightsSavedSearchResults `
-ResourceGroupName $ResourceGroupName `
-WorkspaceName $WorkSpaceName `
-SavedSearchId "test|upgra_search1"
$Apps = $result.value | ConvertFrom-Json

# saved search 2
$result = Get-AzureRmOperationalInsightsSavedSearchResults `
-ResourceGroupName $ResourceGroupName `
-WorkspaceName $WorkSpaceName `
-SavedSearchId "test|Drivers"
$Drivers = $result.value | ConvertFrom-Json

# A custom query
$dynamicQuery = "* Type=MyComputers_CL"
$result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $dynamicQuery -Top 100
$result.Value | ConvertFrom-Json

$dynamicQuery = "* Type=MyData1_CL"
$result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $dynamicQuery -Top 100
$result.Value | ConvertFrom-Json

$dynamicQuery = "AlexComputerInfo_CL"
$result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $dynamicQuery -Top 100
$result.Value | ConvertFrom-Json

$dynamicQuery = ""

$schema = Get-AzureRmOperationalInsightsSchema -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName
$schemas = $schema.Value #| Select-Object Name| Sort-Object Name


$datainfo = @()
ForEach($s in $schemas)
{
    $dynamicQuery = "$($s.name)=*"
    $result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName -Query $dynamicQuery -Top 10
    $hasdata = $result.Value | ConvertFrom-Json
    If ($hasdata -eq $null)
        {
            write-host "class $($s.name) has no log data" -ForegroundColor DarkGreen
        }
    Else
        {
            write-host "class $($s.name) contains log data" -ForegroundColor Green
            $datainfo += "$($s.Name)"
        }
}
$datainfo





