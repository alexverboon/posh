Function Get-CMclientpolicysettings
{
<#
.Synopsis
   Get-CMclientpolicysettings
.DESCRIPTION
   Get-CMclientpolicysettings retrieves Configuration Manager client agent policy settings. 
.PARAMETER Name
   The ConfigMgr Agent Policy Name
.EXAMPLE
   Get-CMclientpolicysettings
.EXAMPLE
    Get-CMclientpolicysettings -Name "Workstation Settings"
.NOTES
    version 1.1, 21.02.2017, Alex Verboon
#>

[CmdletBinding()]
Param(

        # ConfigMgr Agent Policy Name
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Name
)

Begin{

    Write-verbose "Retrieving Policies"
    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $cmpolicies = Get-CMClientSetting | Select-Object Name | Where-Object {$_.Name -eq "$Name"}
    }
    Else
    {
        $cmpolicies = Get-CMClientSetting | Select-Object Name 
    }
}


Process{
    $Results = @()
    foreach ($policy in $cmpolicies ) 
    {
        write-verbose "$($Policy.name)" 
	    $xsettings = [Enum]::GetNames( [Microsoft.ConfigurationManagement.Cmdlets.ClientSettings.Commands.SettingType])
	    foreach ($setting in $xsettings)
        {
            Write-verbose $setting
	        $configuration = Get-CMClientSetting -Setting $setting -Name $Pol.name
            ForEach ($config in $configuration.GetEnumerator())
            {
                write-verbose $config.Key
                $data  = [ordered] @{
                PolicyName = $policy.Name
                Setting = $setting
                ConfigurationName = $config.Key
                ConfigurationValue = $config.Value
                }
            $Results += (New-Object -TypeName psobject -Property $data)
            }
        }
    }
}

End{Write-Output $Results}

}