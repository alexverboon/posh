
Function Test-OpenPorts
{
<#
.SYNOPSIS
    Test-OpenPorts
.DESCRIPTION
    Test-OpenPorts, a quick and dirty script i put together to test open ports

    a better one can be found here
    https://github.com/BornToBeRoot/PowerShell_IPv4PortScanner/blob/master/Scripts/IPv4PortScan.ps1


.PARAMETER Scope
 All = Test all ports from 1 - 65535
 Top128 = Top128 ports
 1-1024 = Port 1 - 1024
.NOTES
    idea and some code taken from here:
    http://www.blackhillsinfosec.com/?p=4811


#>
    [CmdletBinding()]
    Param(
            # Param1 help description
        [Parameter( ParameterSetName='Scope',
        Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet(“All”,”Top128”,"1-1024")] 
        [string]$Scope,

        [Parameter( ParameterSetName='Scope',
        Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$Target="allports.exposed"
)

Begin{

    $Result = @()
    Write-Verbose "Target: $Target"
}


Process{





        If ($Scope -eq "All")
        {
            Write-Verbose "Testing all 65535  ports" 
            1..65535 | % {$test= new-object system.Net.Sockets.TcpClient; 
            $wait = $test.beginConnect("$Target",$_,$null,$null); 
            ($wait.asyncwaithandle.waitone(250,$false)) | Out-Null
            
            if($test.Connected)
            {
                Write-Verbose "Port $_ open"
                $Data = [ordered] @{
                Port = $_
                Result = "Open"
                }
                $Result += (New-Object PSObject -Property $Data)
            }
            Else
            {
                Write-Verbose "Port $_ closed"
                $Data = [ordered] @{
                Port = $_
                Result = "closed"
                }
                $Result += (New-Object PSObject -Property $Data)
        }
    }
        }
    

        If ($Scope -eq "1-1024")
        {
            Write-Verbose "Testing ports 1 - 1024" 
            1..1024 | % {$test= new-object system.Net.Sockets.TcpClient; 
            $wait = $test.beginConnect("$Target",$_,$null,$null); 
            ($wait.asyncwaithandle.waitone(250,$false)) | Out-Null
        
            if($test.Connected)
            {
                Write-Verbose "Port $_ open"
                $Data = [ordered] @{
                Port = $_
                Result = "Open"
                }
                $Result += (New-Object PSObject -Property $Data)
            }
            Else
            {
                Write-Verbose "Port $_ closed"
                $Data = [ordered] @{
                Port = $_
                Result = "closed"
                }
                $Result += (New-Object PSObject -Property $Data)
            }
        }
        }


        If ($Scope -eq "Top128")
        {
        Write-Verbose "Testing Top 128 ports" 

            $TopPorts = "80","23","443","21","22","25","3389","110","445","139","143","53","135","3306","8080","1723","111","995",
            "993","5900","1025","587","8888","199","1720","465","548","113","81","6001","10000","514","5060","179",
            "1026","2000","8443","8000","32768","554","26","1433","49152","2001","515","8008","49154","1027",
            "5666","646","5000","5631","631","49153","8081","2049","88","79","5800","106",
            "2121","1110","49155","6000","513","990","5357","427","49156","543","544","5101","144","7","389",
            "8009","3128","444","9999","5009","7070","5190","3000","5432","3986","13","1029","9","6646",
            "49157","1028","873","1755","2717","4899","9100","119","37","1000","3001","5001","82","10010",
            "1030","9090","2107","1024","2103","6004","1801","19","8031","1041","255","3703","17","808","3689",
            "1031","1071","5901","9102","9000","2105","636","1038","2601","7000"
                  

            $TopPorts| % {$test= new-object system.Net.Sockets.TcpClient; 
            $wait = $test.beginConnect("$target",$_,$null,$null); 
            ($wait.asyncwaithandle.waitone(250,$false)) | Out-Null
            
            if($test.Connected)
            {
                Write-Verbose "Port $_ open"
                $Data = [ordered] @{
                Port = $_
                Result = "Open"
                }
                $Result += (New-Object PSObject -Property $Data)
            }
            Else
            {
                Write-Verbose "Port $_ closed"
                $Data = [ordered] @{
                Port = $_
                Result = "closed"
                }
                $Result += (New-Object PSObject -Property $Data)
            }
        
        }
    }
    }

End{
    $Result
}

}




