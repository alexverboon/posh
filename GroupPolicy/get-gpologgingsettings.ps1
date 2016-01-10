
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
   http://blogs.technet.com/b/askds/archive/2015/04/17/a-treatise-on-group-policy-troubleshooting-now-with-gpsvc-log-analysis.aspx
#>
function Get-GPServiceDebugStatus
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$Computer
    )

    Begin
    {
        $GPLoggingRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics"
        $GpLoggingRegKey = "GPSvcDebugLevel"

    }
    Process
    {

    ForEach ($c in $Computer)
    {

        # GroupPolicy Logging Status
        $GPLoggingRegStatus = Get-ItemProperty -Path $GPLoggingRegPath -Name $GpLoggingRegKey | Select-Object -ExpandProperty GPSvcDebugLevel
        If ($GPLoggingRegStatus -eq $null -or $GPLoggingRegStatus -eq 0)
        {
            Write-Output "Group Policy Service Debug logging is not enabled"
        }  
        Else
        {
            $GPLoggingRegStatus = '{0:x}' -f $GPLoggingRegStatus
            if ($GPLoggingRegStatus -eq "30002")
            {
                Write-verbose "Group Policy Service Debug logging is enabled"
            }
            Else
            {
                Write-verbose "The value set for GPSvcDebugLevel: $GPLoggingRegStatus is not supported"
            }
         }
    

     New-Object -TypeName psobject -Property @{
     Computer = $c
     GPServiceDebugStatus = $GPLoggingRegStatus
     }
    }

    }

    End
    {
    }
}

