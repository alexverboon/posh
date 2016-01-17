
function Update-GroupPolicyXtended{
    Write-Output "Updating GroupPolicyXtended module" 
    $ScriptURL = "https://raw.githubusercontent.com/alexverboon/posh/master/GroupPolicy/install-GroupPolicyXtended.ps1"
    $wc=New-Object System.Net.WebClient;$wc.UseDefaultCredentials=$true;iex $wc.DownloadString($ScriptURL)
}
Export-ModuleMember -Function Update-GroupPolicyXtended

function Get-GPProcessingtime
{
<#
.Synopsis
   Get Group Policy Processing time from the Group Policy event log on local and remote computers
.DESCRIPTION
   The Get-GPProcessingtime cmdlet gets Group Policy processing time for the user and computer related 
   Group Policies that are processed on the specified computer(s). 

   The last user and computer Group Policy processing event is used.
.EXAMPLE
   Get-GPProcessingtime -Computer TestClient1,TestClient2,TestClient3

   Lists additional details of the Group Policy processing duration information

    Cmp_PrincipalSamName         Cmp_PolicyElaspedTimeInSeconds      Usr_PolicyElaspedTimeInSeconds     
    --------------------         ------------------------------      ------------------------------     
    CORP\TestClient1$               1                                   2                                  
    CORP\TestClient2$               2                                   2                                  
    CORP\TestClient3$               12                                  49 

.EXAMPLE
    Get-GPProcessingtime -Computer TestClient1 -ShowDetails

    Cmp_ID                         : 8004
    Cmp_EventTypeDescription       : Successful computer manual refresh event
    Cmp_Message                    : Completed manual processing of policy for computer CORP\TestClient1$ in 1 
                                     seconds.
    Cmp_TimeCreated                : 8/1/2014 8:13:40 PM
    Cmp_ActivityID                 : e872d44e-1b89-434a-bf79-b1875ec810cf
    Cmp_PolicyElaspedTimeInSeconds : 1
    Cmp_PrincipalSamName           : CORP\TestClient1$
    Cmp_BandwidthInkbps            : 185508
    Cmp_IsSlowLink                 : false
    Cmp_DomainController           : dc01.corp.com
    Usr_ID                         : 8001
    Usr_EventTypeDescription       : Successful user end event
    Usr_Message                    : Completed user logon policy processing for CORP\User1 in 2 seconds.
    Usr_TimeCreated                : 7/30/2014 4:55:42 PM
    Usr_ActivityID                 : 43ca8a03-2b98-4e92-8613-aad67990bca3
    Usr_PolicyElaspedTimeInSeconds : 2
    Usr_PrincipalSamName           : CORP\User1
    Usr_BandwidthInkbps            : 1200750
    Usr_IsSlowLink                 : false
    Usr_DomainController           : dc01.corp.com

.PARAMETER Computer
    Type the NetBIOS name, an Internet Protocol (IP) address, or the fully qualified domain name of the computer. 
    The default value is the local computer.

    To get Group Policy processing information from remote computers, the firewall port for the event log service must 
    be configured to allow remote access.

    This cmdlet does not rely on Windows PowerShell remoting. You can use the ComputerName parameter even 
    if your computer is not configured to run remote commands.
.PARAMETER ShowDetails
    The ShowDetails switch is optional, when set, additonal Group Policy processing information is listed
    such as the type of the Group Policy processing event (periodic, manual) the Activity ID
    Network Bandwidth and the domain controller being contacted.

.LINKS
# http://technet.microsoft.com/library/cc749336.aspx    

#>
[CmdletBinding()]
 Param(
    [Parameter(Mandatory=$False,
    ValueFromPipelineByPropertyName=$true,HelpMessage="Enter Computername(s)",
    Position=0)]
    [Alias("ipaddress","host")]
    [String[]]$Computer = "localhost",
    [switch]$ShowDetails
    )

begin{
    # User Event IDs
    $ugeventcodes = @{
    "8001" = "Successful user end event";
    "8003" = "Successful user network change event";
    "8005" = "Successful user manual refresh event";
    "8007" = "Successful user periodic refresh event";
    "7001" = "Error during user end event";
    "7003" = "Error during user network change event";
    "7005" = "Error during user manual refresh event";
    "7007" = "Error during user periodic refresh event";
    "6001" = "Warnings during user end event";
    "6003" = "Warnings during  user network change event";
    "6005" = "Warnings during  user manual refresh event";
    "6007" = "Warnings during  user periodic refresh event";
    }

    # Computer Event IDs
    $cgeventcodes = @{
    "8000" = "Successful computer end event";
    "8002" = "Successful computer network change event";
    "8004" = "Successful computer manual refresh event";
    "8006" = "Successful computer periodic refresh event";
    "7000" = "Error duing computer end event";
    "7002" = "Error during computer network change event";
    "7004" = "Error during computer manual refresh event";
    "7006" = "Error during computer periodic refresh event";
    "6000" = "Warnings during computer end event";
    "6002" = "Warnings during computer network change event";
    "6004" = "Warnings during  computer manual refresh event";
    "6006" = "Warnings during  computer periodic refresh event";
    }
}
Process{
    $compcount = $Computer.count
    $si=1
    $gpprocessresult = @()

    ForEach ($comp in $Computer)
    {
        If (Test-Connection -ComputerName "$comp" -Count 1 -Quiet)
            {
            $orgCulture = Get-Culture
            [System.Threading.Thread]::CurrentThread.CurrentCulture = New-Object "System.Globalization.CultureInfo" "en-US"
        
            # variable that holds all user related event IDs
            $ueventids = $ugeventcodes.Keys
            # Get last user GP processing event
            $uevent = Get-WinEvent -ComputerName $Comp -filterHashTable @{
             Providername = "Microsoft-Windows-GroupPolicy"
             ID = $($ueventids)
              } -ErrorAction SilentlyContinue | select -first 1 -ErrorAction SilentlyContinue

            # variable that holds all computer related IDs
            $ceventids = $cgeventcodes.Keys
            # Get last computer GP processing event
            $cevent = Get-WinEvent -ComputerName $Comp -filterHashTable @{
             Providername = "Microsoft-Windows-GroupPolicy"
             ID = $($ceventids)
             } -ErrorAction SilentlyContinue | select -first 1 -ErrorAction SilentlyContinue

        
            if (-not ([string]::IsNullOrEmpty($uevent)))
            {
                 # create a variable that holds the user event details
                 $ueventXML = [xml]$uevent.ToXml() 

                 # Retrieve Event with EventID 5308 to get the domain controller name used when processing the user
                 $Query = ' <QueryList><Query Id="0" Path="Application"><Select Path="Microsoft-Windows-GroupPolicy/Operational">*[System/Correlation/@ActivityID="{CorrelationID}"] and *[System[(EventID="5308")]] </Select></Query></QueryList>'
                 $FilterXML = $Query.Replace("CorrelationID",$uevent.ActivityID)
                 $udc = Get-WinEvent -FilterXml $FilterXML -ComputerName $comp -ErrorAction SilentlyContinue | select -First 1 -ErrorAction SilentlyContinue
                 if (-not ([string]::IsNullOrEmpty($udc)))
                 {$udcevent = [xml]$udc.ToXml()
                 $udcname = $udcevent.event.EventData.Data[0]."#Text"
                 }  

                 # Retrieve Event with EventID 5314 to get network information when processing user 
                 $Query = ' <QueryList><Query Id="0" Path="Application"><Select Path="Microsoft-Windows-GroupPolicy/Operational">*[System/Correlation/@ActivityID="{CorrelationID}"] and *[System[(EventID="5314")]] </Select></Query></QueryList>'
                 $FilterXML = $Query.Replace("CorrelationID",$uevent.ActivityID)
                 $unw = Get-WinEvent -FilterXml $FilterXML -ComputerName $comp -ErrorAction SilentlyContinue | select -First 1 -ErrorAction SilentlyContinue
                 if (-not ([string]::IsNullOrEmpty($unw)))
                 {$unwevent = [xml]$unw.ToXml()
                 $uBandwidthInkbps = $unwevent.event.EventData.Data[0]."#Text"
                 $uIsSlowLink = $unwevent.event.EventData.Data[1]."#Text"
                 }  
            }

            if (-not ([string]::IsNullOrEmpty($cevent)))
            {
                 # create a variable that holds the computer event details
                 $ceventXML = [xml]$cevent.ToXml() 

                 # Retrieve Event with EventID 5308 to get the domain controller name when processing the computer
                 $Query = ' <QueryList><Query Id="0" Path="Application"><Select Path="Microsoft-Windows-GroupPolicy/Operational">*[System/Correlation/@ActivityID="{CorrelationID}"] and *[System[(EventID="5308")]] </Select></Query></QueryList>'
                 $FilterXML = $Query.Replace("CorrelationID",$cevent.ActivityID)
                 $cdc = Get-WinEvent -FilterXml $FilterXML -ComputerName $comp -ErrorAction SilentlyContinue | select -First 1 -ErrorAction SilentlyContinue
                 if (-not ([string]::IsNullOrEmpty($cdc)))
                 {$cdcevent = [xml]$cdc.ToXml() 
                 $cdcname = $cdcevent.event.EventData.Data[0]."#Text"
                 } 

                 # Retrieve Event with EventID 5314 to get network information when processing computer 
                 $Query = ' <QueryList><Query Id="0" Path="Application"><Select Path="Microsoft-Windows-GroupPolicy/Operational">*[System/Correlation/@ActivityID="{CorrelationID}"] and *[System[(EventID="5314")]] </Select></Query></QueryList>'
                 $FilterXML = $Query.Replace("CorrelationID",$cevent.ActivityID)
                 $cnw = Get-WinEvent -FilterXml $FilterXML -ComputerName $comp -ErrorAction SilentlyContinue | select -First 1 -ErrorAction SilentlyContinue
                 if (-not ([string]::IsNullOrEmpty($unw)))
                 {$cnwevent = [xml]$cnw.ToXml()
                 $cBandwidthInkbps = $cnwevent.event.EventData.Data[0]."#Text"
                 $cIsSlowLink = $cnwevent.event.EventData.Data[1]."#Text"
                 }  
           }

            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name Cmp_ID -Value $cevent.Id
            $object | Add-Member -MemberType NoteProperty -Name Cmp_EventTypeDescription -Value $cgeventcodes["$($cevent.Id)"]
            $object | Add-Member -MemberType NoteProperty -Name Cmp_Message -Value $cevent.Message
            $object | Add-Member -MemberType NoteProperty -Name Cmp_TimeCreated -Value $cevent.TimeCreated
            $object | Add-Member -MemberType NoteProperty -Name Cmp_ActivityID -Value $cevent.ActivityId
            $object | Add-Member -MemberType NoteProperty -Name Cmp_PolicyElaspedTimeInSeconds -Value ($cpe = If ([string]::IsNullOrEmpty($cevent)) {} else {  $ceventXML.Event.EventData.Data[0].'#text'})
            $object | Add-Member -MemberType NoteProperty -Name Cmp_PrincipalSamName -Value ($cpn = If ([string]::IsNullOrEmpty($cevent)) {} else { $ceventXML.Event.EventData.Data[2].'#text' })
            $object | Add-Member -MemberType NoteProperty -Name Cmp_BandwidthInkbps -Value $cBandwidthInkbps
            $object | Add-Member -MemberType NoteProperty -Name Cmp_IsSlowLink -Value $cIsSlowLink
            $object | Add-Member -MemberType NoteProperty -Name Cmp_DomainController -Value $cdcname

            $object | Add-Member -MemberType NoteProperty -Name Usr_ID -Value $uevent.Id
            $object | Add-Member -MemberType NoteProperty -Name Usr_EventTypeDescription -Value $ugeventcodes["$($uevent.Id)"]
            $object | Add-Member -MemberType NoteProperty -Name Usr_Message -Value $uevent.Message
            $object | Add-Member -MemberType NoteProperty -Name Usr_TimeCreated -Value $uevent.TimeCreated
            $object | Add-Member -MemberType NoteProperty -Name Usr_ActivityID -Value $uevent.ActivityId
            $object | Add-Member -MemberType NoteProperty -Name Usr_PolicyElaspedTimeInSeconds -Value ($Upe = If ([string]::IsNullOrEmpty($uevent)) {} else {  $ueventXML.Event.EventData.Data[0].'#text'})
            $object | Add-Member -MemberType NoteProperty -Name Usr_PrincipalSamName -Value ($upn = If ([string]::IsNullOrEmpty($uevent)) {} else { $ueventXML.Event.EventData.Data[2].'#text' })
            $object | Add-Member -MemberType NoteProperty -Name Usr_BandwidthInkbps -Value $uBandwidthInkbps
            $object | Add-Member -MemberType NoteProperty -Name Usr_IsSlowLink -Value $uIsSlowLink
            $object | Add-Member -MemberType NoteProperty -Name Usr_DomainController -Value $udcname
            $gpprocessresult += $object
            }
            Else
            {
                write-output "Client $comp is NOT reachable, skipping"
            }
            Write-Progress -Activity "Processing $comp" -Status "Processing $si of $compcount" -PercentComplete (($si / $compcount) * 100)
            $si++
       }
}

End{
    If ($ShowDetails.IsPresent -eq $false)
        {$gpprocessresult | Select Cmp_PrincipalSamName, Cmp_PolicyElaspedTimeInSeconds,Usr_PolicyElaspedTimeInSeconds}
    Else
        {$gpprocessresult}
    }
}

Set-Alias gppt Get-GPProcessingtime
Export-ModuleMember -Function Get-GPProcessingtime -Alias gppt

function Get-GPEventByCorrelationID
{
<#
.Synopsis
   Get Group Policy Eventlog entries by Correlation ID
.DESCRIPTION
   This function retrieves Group Policy event log entries filtered by Correlation ID from the specified computer
.EXAMPLE
   Get-GPEventByCorrelationID -Computer TestClient -CorrelationID A2A621EC-44B4-4C56-9BA3-169B88032EFD 
 
TimeCreated                     Id LevelDisplayName Message                                                          
-----------                     -- ---------------- -------                                                          
7/28/2014 5:31:31 PM          5315 Information      Next policy processing for CORP\CHR59104$ will be attempted in...
7/28/2014 5:31:31 PM          8002 Information      Completed policy processing due to network state change for co...
7/28/2014 5:31:31 PM          5016 Information      Completed Audit Policy Configuration Extension Processing in 0...
.......
 
#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        HelpMessage="Enter Computername(s)",
        Position=0)]
        [String]$Computer = "localhost",
        # CorrelationID
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        HelpMessage="Enter CorrelationID",
        Position=0)]
        [string]$CorrelationID
        )
 
    Begin
    {
        $Query = '<QueryList><Query Id="0" Path="Application"><Select Path="Microsoft-Windows-GroupPolicy/Operational">*[System/Correlation/@ActivityID="{CorrelationID}"]</Select></Query></QueryList>'
        $FilterXML = $Query.Replace("CorrelationID",$CorrelationID)
    }
    Process
    {
        $orgCulture = Get-Culture
        [System.Threading.Thread]::CurrentThread.CurrentCulture = New-Object "System.Globalization.CultureInfo" "en-US"
        $gpevents = Get-WinEvent -FilterXml $FilterXML -ComputerName $Computer
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $orgCulture
    }
    End
    {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = New-Object "System.Globalization.CultureInfo" "en-US"
        $gpevents | Format-Table -Wrap -AutoSize -Property TimeCreated, Id, LevelDisplayName, Message
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $orgCulture
     }
}

Set-Alias gpevtcor Get-GPEventByCorrelationID
Export-ModuleMember -Function Get-GPEventByCorrelationID -Alias gpevtcor

function Get-GPLogging
{
<#
.Synopsis
   Retrieves the Group Policy Service Debug or Group Policy Preferences logging
   configuration.
.DESCRIPTION
   The Get-GPLogging cmdlet retrieves information about the Group Policy Service Debug
   or Group Policy Preference logging configuration set on a computer. 

   Group Policy Service Debugging is configured through the following registry setting:
   Key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\Diagnostics 
   SubKey: GPSvcDebugLevel
   Value: DWORD:30002 (196610)

   Group Policy Registry* Preference logging is configured through the following registry settings:

   Key: HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy
   Key: {B087BE9D-ED37-454f-AF9C-04291E351182}
   SubKeys: TraceLevel,LogLevel,TraceFileMaxSize,TraceFilePathMachine,TraceFilePathUser,TraceFilePathPlanning

   * Each prefeence has its own pre-defined GUID

.EXAMPLE
   Get-Get-GPLogging -Computer Computer1 -GPService

    Computer             : Computer1
    GPServiceDebugValue  : 30002
    GPServiceDebugStatus : Enabled
    GroupPolicyService   : Running
    Online               : True

    The above command lists the Group Policy Service Debug configuration

.EXAMPLE
 Get-GPLogging -Computer Computer1 -GPPreferences

    Computer              : Computer1
    Online                : True
    Preference            : Registry
    PreferenceGUID        : {B087BE9D-ED37-454f-AF9C-04291E351182}
    TraceLevel            : 2
    LogLevel              : 3
    TraceFileMaxSize      : 1024
    TraceFilePathMachine  : %COMMONAPPDATA%\GroupPolicy\Preference\Trace\Computer.log
    TraceFilePathPlanning : %COMMONAPPDATA%\GroupPolicy\Preference\Trace\Planning.log
    TraceFilePathUser     : %COMMONAPPDATA%\GroupPolicy\Preference\Trace\User.log
    PSComputerName        : chr596bd
    RunspaceId            : f11de047-ad74-4533-a711-87367ba3419f

    The above command lists the Group Policy Preference configuration of

.PARAMETER Computer
 One or multiple computer names 

.PARAMETER GPService
 Instructs the script to return Group Policy Service Debug configuration information

.PARAMETER GPPreferences
 Instructs the script to return Group Policy Preferences logging information

.NOTES
    Version 1.0, Alex Verboon
#>

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$Computer,

        [Parameter(Mandatory=$true,
        ParameterSetName = "GPService",
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
        [switch]$GPService,

        [Parameter(Mandatory=$true,
        ParameterSetName = "Preferences",
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
        [switch]$GPPreferences
    )

    Begin
    {

    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
        {   
        Write-Output "Please launch the PowerShell Console as administrator"
        Break
        }

        if ($PSBoundParameters.ContainsKey("GPService"))
        {
          $Mode = "GPService"
        }
        
         if ($PSBoundParameters.ContainsKey("GPPreferences"))
        {
          $Mode = "GPPreferences"
        }
    }

Process
{
    ForEach ($comp in $Computer)
    {
        Write-Verbose "Processing computer: $comp"
        If (Test-Connection -ComputerName "$comp" -Count 1 -Quiet)
        {
            Write-Verbose "Computer: $comp is online"
            if ($Mode -eq "GPService")
            {
                    $ret = Invoke-Command -ComputerName $comp -ScriptBlock {
                    $ClientOnline = $true
                    $VerbosePreference=$Using:VerbosePreference
                    $GPLoggingRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics"
                    $GpLoggingRegKey = "GPSvcDebugLevel"

                    $GPLoggingRegStatus = Get-ItemProperty -Path $GPLoggingRegPath -Name $GpLoggingRegKey -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GPSvcDebugLevel 
                    Write-Verbose "GPSvcDebugLevel: $GPLoggingRegStatus"
                
                    If ($GPLoggingRegStatus -eq $null -or $GPLoggingRegStatus -eq 0)
                    {
                        Write-verbose "Group Policy Service Debug logging is not enabled"
                        $GPLoggingRegStatus = 0
                        $GPLoggingRegStatusDesc = "Disabled"
                    }  
                    Else
                    {
                        $GPLoggingRegStatus = '{0:x}' -f $GPLoggingRegStatus
                        if ($GPLoggingRegStatus -eq "30002")
                        {
                            Write-verbose "Group Policy Service Debug logging is enabled"
                            $GPLoggingRegStatusDesc = "Enabled"
                        }
                        Else
                        {
                            Write-verbose "The value set for GPSvcDebugLevel: $GPLoggingRegStatus is not supported"
                            $GPLoggingRegStatusDesc = "Invalid"
                        }
                     }
                    $gpsvcservicestatus = (Get-Service -Name gpsvc).Status
                    Write-Verbose "Group Policy Service Status: $gpsvcservicestatus"
                    $ret = $GPLoggingRegStatus, $GPLoggingRegStatusDesc,$gpsvcservicestatus,$ClientOnline
                    $ret
                } 
            }


            if ($Mode -eq "GPPreferences")
            {
                    $ret = Invoke-Command -ComputerName $comp -ScriptBlock {
                    $ClientOnline = $true
                    $VerbosePreference=$Using:VerbosePreference
                    $regpath =  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy"
                    $gpguids = Get-ItemProperty -Path "$regpath\*" | Select-Object -ExpandProperty PSChildName 

                    ForEach ($gppref in $gpguids)
                    {
                            switch($gppref)
                            {
                            "{F9C77450-3A41-477E-9310-9ACD617BD9E3}"   {$prefname = "Applications"};
                            "{728EE579-943C-4519-9EF7-AB56765798ED}"   {$prefname = "DataSources"};
                            "{1A6364EB-776B-4120-ADE1-B63A406A76B5}"   {$prefname = "Devices"};
                            "{5794DAFD-BE60-433f-88A2-1A31939AC01F}"   {$prefname = "DriveMaps"};
                            "{0E28E245-9368-4853-AD84-6DA3BA35BB75}"   {$prefname = "Environment"};
                            "{7150F9BF-48AD-4da4-A49C-29EF4A8369BA}"   {$prefname = "Files"};
                            "{A3F3E39B-5D83-4940-B954-28315B82F0A8}"   {$prefname = "FolderOptions"}; 
                            "{6232C319-91AC-4931-9385-E70C2B099F0E}"   {$prefname = "Folder"};
                            "{74EE6C03-5363-4554-B161-627540339CAB}"   {$prefname = "IniFiles"};
                            "{E47248BA-94CC-49c4-BBB5-9EB7F05183D0}"   {$prefname = "InternetSettings"};
                            "{17D89FEC-5C44-4972-B12D-241CAEF74509}"   {$prefname = "LocalUsersGroups"};
                            "{6A4C88C6-C502-4f74-8F60-2CB23EDC24E2}"   {$prefname = "NetWorkShares"};
                            "{3A0DBA37-F8B2-4356-83DE-3E90BD5C261F}"   {$prefname = "NetWorkOptions"};
                            "{E62688F0-25FD-4c90-BFF5-F508B9D2E31F}"   {$prefname = "PowerOptions"};
                            "{B087BE9D-ED37-454f-AF9C-04291E351182}"   {$prefname = "Registry"};
                            "{BC75B1ED-5833-4858-9BB8-CBF0B166DF9D}"   {$prefname = "Printers"};
                            "{E5094040-C46C-4115-B030-04FB2E545B00}"   {$prefname = "RegionalOptions"};
                            "{AADCED64-746C-4633-A97C-D61349046527}"   {$prefname = "ScheduledTasks"};
                            "{91FBB303-0CD5-4055-BF42-E512A681B325}"   {$prefname = "Services"};
                            "{C418DD9D-0D14-4efb-8FBF-CFE535C8FAC7}"   {$prefname = "Shortcuts"};
                            "{E4F48E54-F38D-4884-BFB9-D4D2E5729C18}"   {$prefname = "StartMenu"};
                            default {$prefname = "Undefined GUID in script"}
                            } 

                            $TraceLevel = Get-ItemProperty -Path "$regpath\$gppref" -Name "TraceLevel" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty TraceLevel
                            $LogLevel =  Get-ItemProperty -Path "$regpath\$gppref" -Name "LogLevel" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty LogLevel
                            $TraceFileMaxSize =  Get-ItemProperty -Path "$regpath\$gppref" -Name "TraceFileMaxSize" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty TraceFileMaxSize
                            $TraceFilePathMachine =  Get-ItemProperty -Path "$regpath\$gppref" -Name "TraceFilePathMachine" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty TraceFilePathMachine
                            $TraceFilePathPlanning =  Get-ItemProperty -Path "$regpath\$gppref" -Name "TraceFilePathPlanning" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty TraceFilePathPlanning
                            $TraceFilePathUser =  Get-ItemProperty -Path "$regpath\$gppref" -Name "TraceFilePathUser" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty TraceFilePathUser
                    
                            $props = [ordered]@{
                            Computer = $using:comp
                            Preference = $prefname
                            PreferenceGUID = $gppref
                            TraceLevel = $TraceLevel
                            LogLevel = $LogLevel
                            TraceFileMaxSize = $TraceFileMaxSize
                            TraceFilePathMachine = $TraceFilePathMachine
                            TraceFilePathPlanning = $TraceFilePathPlanning
                            TraceFilePathUser = $TraceFilePathUser
                            }
                            $data += @(New-Object pscustomobject -Property $props)
                    }
                    $ret = $data
                    $ret
               }
            }
        }
        Else
        {
            $ClientOnline = $false
            Write-Verbose "Computer $comp is not online"
            #$ret = "0","unknown","unknown","$ClientOnline"
        }


        if ($Mode -eq "GPService")
        {
             $props = [ordered]@{
             Computer = $comp
             GPServiceDebugValue = $ret[0]
             GPServiceDebugStatus = $ret[1]
             GroupPolicyService = $ret[2]
             }
             $Results += @(New-Object pscustomobject -Property $props)
        }

        if ($Mode -eq "GPPreferences")
        {
            $props = [ordered]@{
            Computer = $comp
            LogData = $ret
            }
            $Results += @(New-Object pscustomobject -Property $props)
        }
    } 
} 

End
{
    if ($Mode -eq "GPService")
    {
        $Results
    }

    if ($Mode -eq "GPPreferences")
    {
        $Results = $Results | Select-Object -ExpandProperty LogData
        $Results
    }
}
}

Set-Alias getgplogmode Get-GPLogging
Export-ModuleMember -Function Get-GPLogging -Alias getgplogmode



function Set-GPLogging
{
<#
.Synopsis
   Enables or Disables Group Policy Service or Group Policy Preferences logging
.DESCRIPTION
   The Set-GPLogging cmdlet enables or disables Group Policy Service or Group Policy Preferences
   logging. 

.EXAMPLE
  Set-GPLogging -Computer Computer1 -GPService -Action Enable

    Computer             : Computer1
    ScriptMode           : GPService
    GPServiceDebugValue  : 30002
    GPServiceDebugStatus : Enabled
    GroupPolicyService   : Running
    Action               : Enable
    PreferenceChanged    : 

  This command enables Group Policy Service debug mode. Group Poliy procesing information is being
  written to "C:\Windows\debug\usermode\gpsvc.log"

.EXAMPLE
  Set-GPLogging -Computer Computer1 -GPService -Action Disable

    Computer             : Computer1
    ScriptMode           : GPService
    GPServiceDebugValue  : 0
    GPServiceDebugStatus : Disabled
    GroupPolicyService   : Running
    Action               : Disable
    PreferenceChanged    : 

  This command disables Group Policy Service debug mode. 

.EXAMPLE
  Set-GPLogging -Computer Computer1 -Preferencelog Registry -Action Enable

    Computer             : Computer1
    ScriptMode           : Preferencelog
    GPServiceDebugValue  : 
    GPServiceDebugStatus : Disabled
    GroupPolicyService   : Running
    Action               : Enable
    PreferenceChanged    : Registry

  This command enables Registry Group Policy Preferences logging. Logging information is being written
  into the C:\ProgramData\GroupPolicy\Preference\Trace folder. 

.EXAMPLE
  Set-GPLogging -Computer Computer1 -Preferencelog Registry -Action Disable

    Computer             : Computer1
    ScriptMode           : Preferencelog
    GPServiceDebugValue  : 
    GPServiceDebugStatus : Disabled
    GroupPolicyService   : Running
    Action               : Disable
    PreferenceChanged    : Registry

  This command disables Registry Group Policy Preferences logging.

.EXAMPLE
  Set-GPLogging -Computer Computer -Preferencelog Registry -LogLevel 3 -TraceLevel 2 -Action Enable

  This command enables Registry Group Policy Preferences logging and sets the loglevel and tracelevel. 
  Logging information is being written   into the C:\ProgramData\GroupPolicy\Preference\Trace folder. 

.OUTPUT

  Set-GPLogging returns the following information

    Computer             : Computername
    ScriptMode           : Preferencelog OR GPService (depends on script mode used)   
    GPServiceDebugValue  : 30002 OR 0
    GPServiceDebugStatus : Enabled OR Disabled
    GroupPolicyService   : Running OR Stopped
    Action               : Disable OR Disable
    PreferenceChanged    : Name of the Preference changed (only in Preferencelog mode)

.PARAMETER Computer
 One or multiple computer names

.PARAMETER GPService
    Instructs the script to manage the Group Policy Service debug mode setting

.PARAMETER Preferencelog
    Instructs the script to manage the Group Policy Preferences logging settings

.PARAMETER LogLevel
    Optional when using the Preferencelog mode. 
    LogLevel 3 = Information, Warning and Errors, 2 = Warning and Errors, 1 = Errors Only, 0 = None

    If the parameter is not used Loglevel 3 is set by default. 

.PARAMETER TraceLevel
    Optional when using the Preferencelog mode. 
    TraceLevel 0 = Off / 2 = On

    if the parameter is not used TraceLevel 2 is set by default. 

.PARAMETER Action
   Enable / Disable

   Enables the specified Group Policy logging option
   Disable removes the specified Group Policy logging option
  

.NOTES
    Version 1.0 Alex Verboon, Initial Release
    version 1.1 Alex Verboon, Minor update to force preference settings when keys already exist. 
    Version 1.2 Alex Verboon, alligned parameters to the Get-GPLogging cmdlet
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
        [string[]]$Computer,
        
        [Parameter(Mandatory=$true,
        ParameterSetName = "GPService",
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
        [switch]$GPService,
    
        [Parameter(Mandatory=$true,
        ParameterSetName = "Preferences",
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
        [ValidateSet("Registry","Services","Applications","DataSources","Devices","DriveMaps","Environment","Files","FolderOptions","Folder","IniFiles","InternetSettings","LocalUsersGroups","NetWorkShares","NetWorkOptions","PowerOptions","Printers","RegionalOptions","ScheduledTasks","Shortcuts","StartMenu")]
        [string]$Preferencelog,

        [Parameter(Mandatory=$false,
        ParameterSetName = "Preferences",
        ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("3","2","1",'0')]
        [string]$LogLevel = "3",

        [Parameter(Mandatory=$false,
        ParameterSetName = "Preferences",
        ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("2",'0')]
        [string]$TraceLevel = "2",

        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("Enable","Disable")] 
        [string]$Action
    )

Begin
{
    	If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
        {   
            Write-Output "Please launch the PowerShell Console as administrator"
            Break
        }

        if ($PSBoundParameters.ContainsKey("GPService"))
        {
          $Mode = "GPService"
        }
        
         if ($PSBoundParameters.ContainsKey("Preferencelog"))
        {
          $Mode = "Preferencelog"
        }
}


Process
{
    ForEach ($comp in $Computer)
    {
        If (Test-Connection -ComputerName "$comp" -Count 1 -Quiet)
        {
            $ret = Invoke-Command -ComputerName $comp -ScriptBlock {
            $ClientOnline = $true
            $VerbosePreference=$Using:VerbosePreference
            $GPLoggingRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics"
            $GpLoggingRegKey = "GPSvcDebugLevel"

            if ($using:Mode -eq "GPService")
            {
                Write-Verbose "Mode: GPService"
                    If ($using:Action -eq "Enable")
                    {
                        Write-Verbose "Enabling"
                        $usermode = $env:windir + "\debug\usermode"
                        If(!(test-path -Path $usermode))
                        {
                            New-Item -path  $env:windir"\debug" -ItemType Directory -ErrorAction SilentlyContinue | out-null
                            New-Item -Path $usermode -ItemType Directory | out-null 
                        }

                        $regpath =  "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
                        New-Item -path $regpath -name "Diagnostics" -ErrorAction SilentlyContinue | Out-Null
                        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics" -Name "GPSvcDebugLevel" -PropertyType DWORD -Value 196610 -ErrorAction SilentlyContinue | Out-Null
                        $GPLoggingRegStatus = Get-ItemProperty -Path $GPLoggingRegPath -Name $GpLoggingRegKey -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GPSvcDebugLevel 
                        Write-Verbose "GPSvcDebugLevel $GPLoggingRegStatus"


                        $GPLoggingRegStatus = '{0:x}' -f $GPLoggingRegStatus
                        if ($GPLoggingRegStatus -eq "30002")
                        {
                            Write-verbose "Successfully enabled Group Policy Service Debug mode"
                            $GPLoggingRegStatusDesc = "Enabled"
                        }
                        Else
                        {
                            Write-verbose "Enableing Group Policy Service Debug mode failed"
                            $GPLoggingRegStatusDesc = "failed" 
                        }
                    }
                    
                    If ($using:Action -eq "Disable")
                    {
                        Write-Verbose "Disabling"
                        $regpath =  "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
                        Remove-Itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics" -Name "GPSvcDebugLevel" -ErrorAction SilentlyContinue | Out-Null
                        $GPLoggingRegStatus = Get-ItemProperty -Path $GPLoggingRegPath -Name $GpLoggingRegKey -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GPSvcDebugLevel 
                        Write-Verbose "GPSvcDebugLevel $GPLoggingRegStatus"

                        If ($GPLoggingRegStatus -eq $null -or $GPLoggingRegStatus -eq 0)
                        {
                            Write-verbose "Successfully enabled Group Policy Service Debug mode"
                            $GPLoggingRegStatus = 0
                            $GPLoggingRegStatusDesc = "Disabled"
                        }
                        Else
                        {
                            Write-verbose "Disabling Group Policy Service Debug mode failed"
                            $GPLoggingRegStatus = 0
                            $GPLoggingRegStatusDesc = "failed" 
                        }  
                    }
            $gpsvcservicestatus = (Get-Service -Name gpsvc).Status
            $ret = $GPLoggingRegStatus, $GPLoggingRegStatusDesc,$gpsvcservicestatus,$using:Action,$PreferenceChanged
            $ret
            }

            if ($using:Mode -eq "Preferencelog")
            {
                Write-Verbose "Mode = Preferencelog"
                Write-Verbose "Preference to change = $using:Preferencelog"
                $PreferenceChanged = $using:Preferencelog

                    switch($using:Preferencelog)
                    {
                    "Applications"       {$plogpath = "{F9C77450-3A41-477E-9310-9ACD617BD9E3}"};
                    "DataSources"        {$plogpath = "{728EE579-943C-4519-9EF7-AB56765798ED}"};
                    "Devices"            {$plogpath = "{1A6364EB-776B-4120-ADE1-B63A406A76B5}"};
                    "DriveMaps"          {$plogpath = "{5794DAFD-BE60-433f-88A2-1A31939AC01F}"};
                    "Environment"        {$plogpath = "{0E28E245-9368-4853-AD84-6DA3BA35BB75}"};
                    "Files"              {$plogpath = "{7150F9BF-48AD-4da4-A49C-29EF4A8369BA}"};
                    "FolderOptions"      {$plogpath = "{A3F3E39B-5D83-4940-B954-28315B82F0A8}"};
                    "Folder"             {$plogpath = "{6232C319-91AC-4931-9385-E70C2B099F0E}"};
                    "IniFiles"           {$plogpath = "{74EE6C03-5363-4554-B161-627540339CAB}"};
                    "InternetSettings"   {$plogpath = "{E47248BA-94CC-49c4-BBB5-9EB7F05183D0}"};
                    "LocalUsersGroups"   {$plogpath = "{17D89FEC-5C44-4972-B12D-241CAEF74509}"};
                    "NetWorkShares"      {$plogpath = "{6A4C88C6-C502-4f74-8F60-2CB23EDC24E2}"};
                    "NetWorkOptions"     {$plogpath = "{3A0DBA37-F8B2-4356-83DE-3E90BD5C261F}"};
                    "PowerOptions"       {$plogpath = "{E62688F0-25FD-4c90-BFF5-F508B9D2E31F}"};
                    "Registry"           {$plogpath = "{B087BE9D-ED37-454f-AF9C-04291E351182}"};
                    "Printers"           {$plogpath = "{BC75B1ED-5833-4858-9BB8-CBF0B166DF9D}"};
                    "RegionalOptions"    {$plogpath = "{E5094040-C46C-4115-B030-04FB2E545B00}"};
                    "ScheduledTasks"     {$plogpath = "{AADCED64-746C-4633-A97C-D61349046527}"};
                    "Services"           {$plogpath = "{91FBB303-0CD5-4055-BF42-E512A681B325}"};
                    "Shortcuts"          {$plogpath = "{C418DD9D-0D14-4efb-8FBF-CFE535C8FAC7}"};
                    "StartMenu"          {$plogpath = "{E4F48E54-F38D-4884-BFB9-D4D2E5729C18}"};
                    }

                If ($using:Action -eq "Enable")
                {
                    Write-Verbose "Enabling $using:Preferencelog Preference logging"
                    $regpath =  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy"
                    New-Item -path $regpath -name "$plogpath" -ErrorAction SilentlyContinue | Out-Null
                    
                    # LogLevel 3 = Information, Warning and Errors, 2 = Warning and Errors, 1 = Errors Only, 0 = None
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\$plogpath" -Name "LogLevel" -PropertyType DWORD -Value $using:loglevel -Force -ErrorAction SilentlyContinue | Out-Null
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\$plogpath" -Name "TraceFileMaxSize" -PropertyType DWORD -Value 2048 -Force -ErrorAction SilentlyContinue | Out-Null
                    # TraceLevel 0 = Off / 2 = On
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\$plogpath" -Name "TraceLevel" -PropertyType DWORD -Value $using:tracelevel -Force -ErrorAction SilentlyContinue | Out-Null
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\$plogpath" -Name "TraceFilePathMachine" -PropertyType ExpandString -Value "%COMMONAPPDATA%\GroupPolicy\Preference\Trace\Computer_$using:Preferencelog.log" -ErrorAction SilentlyContinue | Out-Null
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\$plogpath" -Name "TraceFilePathUser" -PropertyType ExpandString -Value " %COMMONAPPDATA%\GroupPolicy\Preference\Trace\User_$using:Preferencelog.log" -ErrorAction SilentlyContinue | Out-Null
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\$plogpath" -Name "TraceFilePathPlanning" -PropertyType ExpandString -Value "%COMMONAPPDATA%\GroupPolicy\Preference\Trace\Planning_$using:Preferencelog.log" -ErrorAction SilentlyContinue | Out-Null
                }


                If ($using:Action -eq "Disable")
                {
                    Write-Verbose "Disabling $using:Preferencelog Preference logging"
                    $regpath =  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy"
                    Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\$plogpath" -ErrorAction SilentlyContinue | Out-Null
                }


                $GPLoggingRegStatus = Get-ItemProperty -Path $GPLoggingRegPath -Name $GpLoggingRegKey -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GPSvcDebugLevel 
                $GPLoggingRegStatus = '{0:x}' -f $GPLoggingRegStatus
                if ($GPLoggingRegStatus -eq "30002") {$GPLoggingRegStatusDesc = "Enabled"} Else {$GPLoggingRegStatusDesc = "Disabled"}
                $gpsvcservicestatus = (Get-Service -Name gpsvc).Status
                $ret = $GPLoggingRegStatus, $GPLoggingRegStatusDesc,$gpsvcservicestatus,$using:Action,$PreferenceChanged
                $ret
            }
          } # end invoke-command
        }
        Else
        {
            $ClientOnline = $false
            Write-Verbose "Computer $comp is not reachable"
            #$ret = "0","unknown","unknown","$ClientOnline","none","none"
        }

     $props = [ordered]@{
     Computer = $comp
     ScriptMode = $Mode
     GPServiceDebugValue = $ret[0]
     GPServiceDebugStatus = $ret[1]
     GroupPolicyService = $ret[2]
     Action = $ret[3]
     PreferenceChanged = $ret[4]
     }
     New-Object pscustomobject -Property $props
    } # end foreach 
} #end process 

    End
    {

    }
}

Set-Alias setgplogmode Set-GPLogging
Export-ModuleMember -Function Set-GPLogging -Alias setgplogmode

   
