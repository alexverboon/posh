
Function Get-oldDODhostswhois{

[CmdletBinding()]
Param(
    
)



Begin{

    Write-Verbose "Retrieve content from DoD Internet Host Table March 1985"
    $oldhostsfile = (Invoke-WebRequest -Uri "http://pdp-10.trailing-edge.com/tops20_v6_1_tcpip_installation_tp_ft6/06/new-system/hosts.txt").content
    $oldhostsfile | Out-File -FilePath c:\temp\oldhostsfile.txt -Force


    $hostsfile = Get-Content -Path c:\temp\oldhostsfile.txt
    $regex = [regex] "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
    $total = $hostsfile.count
    $linecnt = 1

}

Process{

$Result = @()
ForEach ($con in $hostsfile)
{

   $ipaddresses =  $regex.Matches($con) 
    
   ForEach ($ip in $ipaddresses)
   {
            write-verbose "Processing $($ip)"
            $ipaddr = "$($_.value)"
      
            Try{
                Write-verbose "Retrieving Whois Data for  $($ip)"
                $whois = Invoke-RestMethod -uri "http://whois.arin.net/rest/ip/$($ip)" 
            }
            Catch{
                $whois = $null
            }

            <#
            Try{
                Write-verbose "Retrieving Remote Host name for  $($_.value)"
                $hostname =  [system.net.dns]::GetHostByAddress(" $($_.value)")
            }
            Catch{
                $hostname = $null
            }
            #>

    $object = [ordered]@{
    IP =  $ip
    WhoisName = $whois.net.orgRef.name
    Whoishandle = $whois.net.orgref.Handle
    Whoisregdate = $whois.net.registrationDate
    WhoisupdateDate = $whois.net.updateDate
    whoisendaddress = $whois.net.endAddress
    whoisnetblockdescr = $whois.net.netBlocks.netBlock.description
    whoisnetblockthype = $whois.net.netBlocks.netBlock.type
    whoisnetblockcidrLength = $whois.net.netBlocks.netBlock.cidrLength
    }
    $Result += (New-Object -TypeName PSObject -Property $object)
    $linecnt++
    Write-verbose "Line: $linecnt / $total"
}
}


}

End{
    $Result
}
}
