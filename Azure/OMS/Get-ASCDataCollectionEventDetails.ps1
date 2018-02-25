
Function Get-ASCDataCollectionEventDetails{

<#
.SYNOPSIS
    Get-ASCDataCollectionEventDetails

.DESCRIPTION
    Get-ASCDataCollectionEventDetails retrieves Event information based
    on a provided set of EventIDs

.PARAMETER Scope
    Minimum or Common

.EXAMPLE
    Get-ASCDataCollectionEventDetails -Scope Minimal -Verbose

    Lists all Event IDs and Event information for the Minimal scope

.NOTES
 https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor
 https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/advanced-security-audit-policy-settings
 https://docs.microsoft.com/en-us/azure/security-center/security-center-enable-data-collection#data-collection-tier
#>


[CmdLetBinding()]
Param(
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateSet('Minimal',"Common")]       
        [string]$Scope
)

Begin{

# Events Inculded in "minimal" data collection 
$Minimal = ("1102","4624","4625","4657","4663","4688","4700","4702","4719","4720","4722","4723","4724","4727","4728","4732","4735","4737","4739","4740","4754","4755","4756","4767","4799","4825","4946","4948","4956","5024","5033","8001","8002","8003","8004","8005","8006","8007","8222")

# Events Inculded in "Common" data collection 
$Common = ("1","299","300","324","340","403","404","410","411","412","413","431","500","501","1100","1102","1107","1108","4608","4610","4611","4614","461","4622",
"4624","4625","4634","4647","4648","4649","4657","4661","4662","4663","4665","4666","4667","4688","4670","4672","4673","4674","4675","4689","4697",
"4700","4702","4704","4705","4716","4717","4718","4719","4720","4722","4723","4724","4725","4726","4727","4728","4729","4733","4732","4735","4737",
"4738","4739","4740","4742","4744","4745","4746","4750","4751","4752","4754","4755","4756","4757","4760","4761","4762","4764","4767","4768","4771",
"4774","4778","4779","4781","4793","4797","4798","4799","4800","4801","4802","4803","4825","4826","4870","4886","4887","4888","4893","4898","4902",
"4904","4905","4907","4931","4932","4933","4946","4948","4956","4985","5024","5033","5059","5136","5137","5140","5145","5632","6144","6145","6272",
"6273","6278","6416","6423","6424","8001","8002","8003","8004","8005","8006","8007","8222","26401","30004")


    If ($Scope -eq "Minimal")
    {
        $EventScope = $Minimal
    }
    ElseIf($Scope -eq "Common")
    {
        $EventScope = $Common
    }
}

Process{
    Write-Verbose "Processing Scope: $Scope"

$EventIDReference = $null
$EventLogProviders = "Microsoft-Windows-Security-Auditing","Microsoft-Windows-AppLocker","Microsoft-Windows-Security-Kerberos","Microsoft-Windows-eventlog","Microsoft-Windows-TaskScheduler","Microsoft-Windows-WinRM","Microsoft-Windows-WinLogon"
ForEach ($entry in $EventLogProviders)
{
    $EventIDList = (Get-Winevent -ListProvider $entry).events
    $EventIDList | Add-Member -MemberType NoteProperty -Name Provider -Value "$entry"
    $EventIDReference = $EventIDReference + $EventIDList
}


$Result = @()

ForEach ($ScopeID in $EventScope)
{
    Write-verbose "Processing EventID $ScopeID"
    $detail =  $EventIDReference | Where-Object {$_.id -eq $ScopeID}

        If ([string]::IsNullOrEmpty($detail))
        {
            $Found = $false
            $Detail = New-Object -TypeName PSObject
            $Detail | Add-Member -Name "ID" -Value $ScopeID -MemberType NoteProperty
        }
        Else
        {
            $Found = $true
        }
    
    ForEach ($detailentry in $detail)
    {
        $object = [ordered] @{
        Id = $ScopeID
        Description = $detailentry.description
        ShortDesription = If([string]::IsNullOrEmpty($detailentry.Description)) {$null} Else {$detailentry.Description.split("`r`n")[0]}
        Level = $detailentry.Level.DisplayName
        LogLink = $detailentry.LogLink.DisplayName
        Provider = $detailentry.provider
        # indicates whether the EventID could be looked up
        Found = $found
        }
        $Result += (New-Object -TypeName PSObject -Property $object)
    }
}
}

End{
    $Result
}
}


