# Azure Automation 
Work Notes and sample scripts I created while learning Azure Automation


## Start-AzureCloudVM_workflow.ps1
Sample of a workflow runbook to start an Azure VM

## Start-AzureCloudVM_script.ps1
Sample of powershell script runbook to start an Azure VM

## Start-AutomationRunbookPS.ps1
Sample of starting an Automation Runbook from PowerShell

## Test-WebHook-StartVM
Sample for trigger a webhook, this script triggers the webhook for
the Test-StartVirtualMachinesFromWebhook workflow.

## Test-StartVirtualMachinesFromWebhook
Sample workflow script that is triggered via a webhook (See Test-WebHook-StartVM)
The script itself starts the VMs that are specified as parameters to the webhook. 




# Documentation references
https://docs.microsoft.com/en-us/azure/automation/automation-solution-vm-management
https://docs.microsoft.com/en-us/azure/automation/automation-first-runbook-textual
https://docs.microsoft.com/en-us/azure/automation/automation-runbook-output-and-messages
https://docs.microsoft.com/en-us/azure/automation/automation-starting-a-runbook#starting-a-runbook-with-windows-powershell

