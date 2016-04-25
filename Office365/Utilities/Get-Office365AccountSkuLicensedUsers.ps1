<#
.Synopsis
   Get-Office365AccountSkuLicensedUsers
.DESCRIPTION
   The Get-Office365AccountSkuLicensedUsers cmdlet retrieves the users that have a specific Office 365
   subscription (AccountSkuId) assigned. 
.EXAMPLE
   Get-Office365LicenseInfo

.PARAMETER AccountSkuId
 The name of an Office 365 AccountSkuId

 A list of known AccountSkuId's pre-populated. 

 Extend the list if needed, a list of known AccountSkuIDs can be found here:
 # http://blogs.technet.com/b/treycarlee/archive/2013/11/01/list-of-powershell-licensing-sku-s-for-office-365.aspx
 
 Other usefull sources related to licensing
 # https://technet.microsoft.com/en-us/library/dn771771.aspx
 # https://technet.microsoft.com/en-us/library/dn771773.aspx

#>
function Get-Office365AccountSkuLicensedUsers
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # AccountSkuId
        [Parameter(Mandatory=$true,
                   ParameterSetName = "AccountSkuId",
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet("ENTERPRISEPACK","RIGHTSMANAGEMENT","AAD_PREMIUM","PLANNERSTANDALONE","POWER_BI_STANDARD")]
        $AccountSkuId
    )

    Begin
    {
 
    }
    Process
    {
        If ($PSBoundParameters.ContainsKey("AccountSkuId"))
        {
            $AccountSkuIdUsers = Get-MsolUser | Select-Object DisplayName,UserPrincipalName -ExpandProperty Licenses |  Where-Object {$_.AccountSkuId -like "*$AccountSkuId*"}
            $AccountSkuIdUsers | Select-Object DisplayName,UserPrincipalName
        }
    }
    End
    {

    }
}









