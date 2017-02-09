
function Add-HybridWorker
{
<#
.Synopsis
   Add-HybridWorker
.DESCRIPTION
   Add-HybridWorker registers a system as Azure Automation Hybrid Worker

   Important: The SCOM/OMS Agent must be installed on the client prior running
   this script. 

.EXAMPLE
    Add-HybridWorker -AutomationAccountName Automation01 -ResourceGroupName RG_automation01 -WorkerGroupName WorkerGrp1
#>
    [CmdletBinding()]
    Param
    (
        # Azure Automation Account Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$AutomationAccountName,
        # Azure Resource Group name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$ResourceGroupName,
        # Hybrid Worker Group Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string]$WorkerGroupName
    )

    Begin
    {
        $cmdout=@{
            Verbose=If ($PSBoundParameters.Verbose -eq $true) { $true } else { $false };
            Debug=If ($PSBoundParameters.Debug -eq $true) { $true } else { $false }
        }

        Write-Verbose "Importing HybridRegistration module"
        $agentversion = (Get-ItemProperty -Path "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\*").Name
        Import-Module "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\$agentversion\HybridRegistration\\HybridRegistration.psd1" @cmdout
    }
    Process
    {
        $automationkeyinfo = Get-AzureRmAutomationRegistrationInfo -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName @cmdout
        Write-Verbose "Registering Computer to $AutomationAccountName in WorkerGroup $WorkerGroupName"
        $cmd = Add-HybridRunbookWorker –Url $automationkeyinfo.Endpoint -Key $automationkeyinfo.PrimaryKey -GroupName $WorkerGroupName @cmdout
    }
    End
    {
    }
}



