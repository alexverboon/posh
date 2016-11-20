<#
.Synopsis
   Get-msoluserlicensestatus
.DESCRIPTION
   Get-msoluserlicensestatus lists all Office 365 Serviceplans,license options
   and provisioning status of these for the specified user
   status
.PARAMETER UserPrincipalName
    The user ID of the user to retrieve.
.EXAMPLE
   Get-msoluserlicensestatus -UserPrincipalName alex@foocorp.com

AccountSkuID                  ServicePlan           ServiceType                   Provisioning
                                                                                        Status
------------                  -----------           -----------                   ------------
   
foocorp:ENTERPRISEWITHSCAL    MCOSTANDARD           MicrosoftCommunicationsOnline      Success
foocorp:ENTERPRISEWITHSCAL    SHAREPOINTWAC         SharePoint                         Success
foocorp:ENTERPRISEWITHSCAL    SHAREPOINTENTERPRISE  SharePoint                         Success
....


.PARAMETER UserPrincipalName
  The user ID of the user to retrieve.
.NOTES
 Version 1.0, 18.11.2016, Alex Verboon
#>
function Get-msoluserlicensestatus
{
    [CmdletBinding()]
    Param
    (
        # The user ID of the user to retrieve.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $UserPrincipalName
    )

    Begin
    {

        Try
        {
            Get-MsolDomain -ErrorAction Stop > $null
        
        }
        catch 
        {
           write-error "You must call the Connect-MsolService cmdlet before calling any other cmdlets" 
           Throw
        }

        $userinfo = Get-MsolUser -UserPrincipalName $UserPrincipalName

    }
    Process
    {

    $licinfo = $userinfo | Select-Object -ExpandProperty licenses
    $output = @()

    ForEach ($i in $licinfo)
    {
        $serviceplan = $i | Select-Object -ExpandProperty ServiceStatus 
        ForEach($sp in $serviceplan)
        {
            $o = [PSCustomObject]@{
            AccountSkuID = $i.AccountSkuId
            #SkuID = ($i.AccountSkuId -split (":"))[1]
            ServicePlan = $sp.ServicePlan.ServiceName
            ServiceType = $sp.ServicePlan.ServiceType
            ProvisioningStatus = $sp.ProvisioningStatus
            #TargetClass = $sp.ServicePlan.TargetClass
            #ServicePlanID = $sp.ServicePlan.ServicePlanId
            }
            $output += $o 
        } 
    }
    }
    End
    {
        $output
    }
}








