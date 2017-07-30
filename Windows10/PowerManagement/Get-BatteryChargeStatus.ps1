
function Get-BatteryChargeStatus
{
<#
.Synopsis
   Get-BatteryChargeStatus
.DESCRIPTION
   Get-BatteryChargeStatus shows the Battery Charging status,
   the remaining Battery capacity in percent and if the system
   is running on Battery.

   The Battery Status can have one of the following values:
   Charging, Discharging, Idle or NotPresent
.PARAMETER Detail
   Displays additional Battery Information

.EXAMPLE
   Get-BatteryChargeStatus

Status Utilization PowerOnline
------ ----------- -----------
Charging        99        True


.EXAMPLE
   Get-BatteryChargeStatus -Detail

ChargeRateInMilliwatts             : 3052
DesignCapacityInMilliwattHours     : 68902
FullChargeCapacityInMilliwattHours : 70222
RemainingCapacityInMilliwattHours  : 69689
Status                             : Charging
Utilization                        : 99
PowerOnline                        : True

.NOTES
 Author: Alex Verboon

 For more information see: 
 https://docs.microsoft.com/en-us/uwp/api/windows.devices.power.batteryreport
 

#>
    [CmdletBinding()]
    Param
    (
        [switch]$Detail
    )

    Begin
    {
        Try{
            $Report = [Windows.Devices.Power.Battery]::AggregateBattery.GetReport() 
        }
        Catch{
            Write-Error "Unable to retrieve Battery Report information"
            Break
        }

        If ($Report.Status -ne "NotPresent")
        {
            $pbmax = [convert]::ToDouble($Report.FullChargeCapacityInMilliwattHours)
            $pbvalue = [convert]::ToDouble($Report.RemainingCapacityInMilliwattHours)
            $Utilization = [int][math]::Round( (($pbvalue / $pbmax) *100))
            $PowerOnlineStatus = (Get-CimInstance -ClassName batterystatus -Namespace root/WMI).PowerOnline

            # Check if at least one battery reports running on power
            If ($PowerOnlineStatus -contains "True")
            {
               $PowerOnline = $true
            }
            Else
            {
               $PowerOnline = $false
            }
        }
        Else
        {
            [int]$Utilization = 0
            $PowerOnline = ""
        }
    }

    Process
    {
        If ($Detail -eq $true)
        {
            $Properties = [ordered] @{
            ChargeRateInMilliwatts = $Report.ChargeRateInMilliwatts
            DesignCapacityInMilliwattHours = $report.DesignCapacityInMilliwattHours
            FullChargeCapacityInMilliwattHours = $Report.FullChargeCapacityInMilliwattHours
            RemainingCapacityInMilliwattHours = $Report.RemainingCapacityInMilliwattHours
            Status = $Report.Status
            Utilization = $Utilization
            PowerOnline = $PowerOnline
            }
            $BatteryChargeStatus = (New-Object -TypeName PSObject -Property $Properties)
        }
        Elseif ($Detail -eq $false)
        {
            $Properties = [ordered] @{
            Status = $Report.Status
            Utilization = $Utilization
            PowerOnline = $PowerOnline
            }
            $BatteryChargeStatus = (New-Object -TypeName PSObject -Property $Properties)
        }
    }
    End
    {
        $BatteryChargeStatus
    }
}













