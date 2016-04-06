<#
.Synopsis
   Get-IscMSSecBulletinInfo
.DESCRIPTION
   Get-IscMSSecBulletinInfo retrieves Microsoft Security bulleting information from
   the SANS Internet Storm Center DShield Rest API https://isc.sans.edu/api
.EXAMPLE
   Get-IscMSSecBulletinInfo -BulletinID MS16-024

    id       : 16026
    title    : Security Update for Graphic Fonts to Address Remote Code Execution
    affected : Microsoft Windows, Microsoft .NET Framework
    kb       : 3143148
    exploits : no
    severity : critical
    clients  : critical
    servers  : critical

.PARAMETER BulletinID
    Microsoft BulletinID Number
    Example: MS16-026
 

.NOTES
    1.0 by Alex Verboon, 6/04/2016
#>
function Get-IscMSSecBulletinInfo
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   HelpMessage="Enter MS Security Bulletin Number",
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $BulletinID
    )

    Begin
    {
    If ([string]::IsNullOrEmpty($BulletinID))
    {
        Write-Output "Microsoft Security Bulletin ID missing"
        break
    }
    $uri = "https://isc.sans.edu/api/getmspatch/$BulletinID" + "?json"

    }
    Process 
    {
        $data = Invoke-WebRequest -Uri $uri
        $bulletininfo = $data.Content | ConvertFrom-Json | Select-Object -ExpandProperty getmspatch -ErrorAction SilentlyContinue
        If ($bulletininfo.kb -eq $null)
        {
            Write-Output "Bulletin ID $BulletinID not found!"
        }
    }
    End
    {
        $bulletininfo
    }
}












