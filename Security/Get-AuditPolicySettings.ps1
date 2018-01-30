
function Get-AuditPolicySettings
{
<#
.Synopsis
   Get-AuditPolicySettings
.DESCRIPTION
   This script pulls the audit policy settings for the local machine
.EXAMPLE
    Get-AuditPolicySettings
.NOTES
    Original script code is from Microsoft, i changed the code so that it displays
    the human readable audit policy names instead of the GUIDs. 
#>

    [CmdletBinding()]
    Param
    ()

    Begin
    {
         If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
         {
        Echo "This script needs to be run As Admin"
        Break
         }
    }
    Process
    {

        $auditPolicy = Auditpol /get /category:* /r
        $result = @()

        for ($i = 1; $i -lt $auditPolicy.Length; $i++) 
        { 
	        if($auditPolicy[$i])
	        {
		        $auditPolicyObj = new-object psobject
		        $splittedStr = $auditPolicy[$i].Split(",")
                $PolicyName=$splittedStr[2]
		        $policyId=$splittedStr[3]
		        $policyId=$policyId.TrimStart("{}")
		        $policyId=$policyId.TrimEnd("}")
		        Add-Member -InputObject $auditPolicyObj -MemberType NoteProperty  -Name PolicyName -Value $PolicyName
		        #Add-Member -InputObject $auditPolicyObj -MemberType NoteProperty  -Name PolicyId -Value $policyId
		        Add-Member -InputObject $auditPolicyObj -MemberType NoteProperty  -Name PolicyValue -Value $splittedStr[4]
		        $result += $auditPolicyObj
	        }
        }
        return $result
    }
    End
    {
    }
}




