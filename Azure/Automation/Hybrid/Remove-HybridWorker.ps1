function Remove-HybridWorker
{
<#
.Synopsis
   Remove-HybridWorker
.DESCRIPTION
   Remove-HybridWorker removes a system from an Azure Hybrid Worker Group

   Important: The SCOM/OMS Agent must be installed on the client prior running
   this script. 

.EXAMPLE
    Remove-HybridWorker -AutomationAccountName Automation01 -ResourceGroupName RG_automation01 
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
        [string]$ResourceGroupName
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
        Write-Verbose "Removing Computer from $AutomationAccountName"
        $cmd = Remove-HybridRunbookWorker -Url $automationkeyinfo.Endpoint -Key $automationkeyinfo.PrimaryKey @cmdout
    }
    End
    {

    }
}



