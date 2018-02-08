Function Get-NetConnectionDetails{
<#
.SYNOPSIS
    Get-NetConnectionDetails
.DESCRIPTION
    Get-NetConnectionDetails retrieves all network connections and then
    retrieves process information and IP information. 

    Use this script to find detailed information about processes and their
    TCP connections. 

.NOTES
    v1.0, 08.02.2018, alex verboon
#>

[CmdletBinding()]
Param()

Begin{
    Try{
        Write-Verbose "Registering geo location lookup"
        $geo = New-WebServiceProxy "http://www.webservicex.net/geoipservice.asmx"
    }
    Catch{
        Write-Warning "Unable to query for Geo data"
   }

    Try{
        Write-Verbose "Retrieving NetTCPConnection data"
       $allconnecctions = Get-NetTCPConnection 
    }
    Catch
    {
        Write-Warning "Unable to retrieve NetTCP Connection data"
        Throw
    }
}

Process{

$Result = @()
ForEach ($con in $allconnecctions)
{
    write-host "Processing $($ProcessIinfo.Name) -- $($con.RemoteAddress)"
    If (-not($con.RemoteAddress -eq "0.0.0.0" -or $con.RemoteAddress -eq "::"))
    {
        Try{
        Write-verbose "Retrieving Geo Data"
        $geodata =  $geo.GetGeoIP("$($con.RemoteAddress)")
        }
        Catch{
            $geodata = $null
        }
      
        Try{
            Write-verbose "Retrieving Whois Data"
            $whois = Invoke-RestMethod -uri "http://whois.arin.net/rest/ip/$($con.RemoteAddress)" 
        }
        Catch{
            $whois = $null
        }

        Try{
            Write-verbose "Retrieving Host name"
            $hostname =  [system.net.dns]::GetHostByAddress("$($con.RemoteAddress)").hostname
        }
        Catch{
            $hostname = $null
        }
    }
    Else
    {
        $geodata = $null
        $whois = $null
    }


    $ProcessID = $con.OwningProcess
    $ProcessIinfo = Get-Process -Id $ProcessID -IncludeUserName 
    $object = [ordered]@{
    ProcessID = $ProcessID
    ProcessName = $ProcessIinfo.Name
    Path = $ProcessIinfo.Path
    FileVersion = $ProcessIinfo.FileVersion
    Company = $ProcessIinfo.Company
    ProductVersion = $ProcessIinfo.ProductVersion
    Description = $ProcessIinfo.Description
    Product = $ProcessIinfo.Product
    User = $ProcessIinfo.UserName
    Session = $ProcessIinfo.SessionId
    cState = $con.State
    cDescription = $con.Description
    cInstanceid = $con.InstanceID
    pTotalProcessorTime = $ProcessIinfo.TotalProcessorTime
    pStartTime = $ProcessIinfo.StartTime
    cCreationTime = $con.CreationTime
    cLocalAddress = $con.LocalAddress
    cLocalPort = $con.LocalPort
    cRemoteAddress = $con.RemoteAddress
    cRemotePort = $con.RemotePort
    HostName = $hostname
    GeoCountry = $geodata.CountryName
    GeoCode = $geodata.CountryCode
    whoisName = $whois.net.orgRef.name
    whoishandle = $whois.net.orgref.Handle
    whoisregdate = $whois.net.registrationDate
    whoisupdateDate = $whois.net.updateDate
    }
    $Result += (New-Object -TypeName PSObject -Property $object)
}

}
End{
    $Result
}
}
