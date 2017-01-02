# quick and dirty script to make a client that has the OMS AGent already installed
# a hybrid worker. 

$ResourceGroupName = "RG_vAutomation1"
$AutomationAccountName = "vAutomation1" 
$HGroupName = "H-WorkerGroup1" 

$agentversion = (Get-ItemProperty -Path "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\*").Name
cd "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\$agentversion\HybridRegistration"
Import-Module .\HybridRegistration.psd1

$automationkeyinfo = Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

Add-HybridRunbookWorker –Url $automationkeyinfo.Endpoint -Key $automationkeyinfo.PrimaryKey -GroupName $HGroupName -Verbose

#Remove-HybridRunbookWorker -Url $automationkeyinfo.Endpoint -Key $automationkeyinfo.PrimaryKey -Verbose



