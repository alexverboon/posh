# Azure Automation


## Azure Automation ISE Add-in
## Installation

### From PowerShell Gallery (recommended)
To install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/AzureAutomationAuthoringToolkit/):
* Open the PowerShell console
* Run `Install-Module AzureAutomationAuthoringToolkit -Scope CurrentUser`

If you want the PowerShell ISE to always automatically load the Azure Automation ISE add-on:
* Run `Install-AzureAutomationIseAddOn`

If not:
* Any time you want to use the Azure Automation ISE add-on in the PowerShell ISE, run `Import-Module AzureAutomationAuthoringToolkit` in the PowerShell ISE
