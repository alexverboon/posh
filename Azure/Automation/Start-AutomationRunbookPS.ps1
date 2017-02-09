# https://docs.microsoft.com/en-us/azure/automation/automation-starting-a-runbook#starting-a-runbook-with-windows-powershell



$runbookName = "Start-AzureCloudVM"
$RbResourceGroupName = "RG_automation01"
$AutomationAcct = "Automation01"
$VMName = "win10vm2"
$ResourceGroupName = "RG_win10vm02"

$params = @{
    Name = $VMName;
    ResourceGroupName = $ResourceGroupName;
}


$job = Start-AzureRmAutomationRunbook –AutomationAccountName $AutomationAcct -Name $runbookName -ResourceGroupName $RbResourceGroupName -Parameters $params

$doLoop = $true
While ($doLoop) {
   $job = Get-AzureRmAutomationJob –AutomationAccountName $AutomationAcct -Id $job.JobId -ResourceGroupName $RbResourceGroupName
   $status = $job.Status
   $doLoop = (($status -ne "Completed") -and ($status -ne "Failed") -and ($status -ne "Suspended") -and ($status -ne "Stopped"))
}

Get-AzureRmAutomationJobOutput –AutomationAccountName $AutomationAcct -Id $job.JobId -ResourceGroupName $RbResourceGroupName –Stream Output 






