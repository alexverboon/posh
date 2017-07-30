
function Get-BatteryChargeStatus
{
<#
.Synopsis
   Get-BatteryChargeStatus
.DESCRIPTION
   Get-BatteryChargeStatus shows the Battery Charging status and
   the remaining Battery capacity in percent. 

   The Battery Status can have one of the following values:
   Charging, Discharging, Idle or NotPresent
.PARAMETER Detail
   Displays additional Battery Information

.EXAMPLE
   Get-BatteryChargeStatus

Status Utilization
------ -----------
Charging        99

.EXAMPLE
   Get-BatteryChargeStatus -Detail

ChargeRateInMilliwatts             : 3052
DesignCapacityInMilliwattHours     : 68902
FullChargeCapacityInMilliwattHours : 70222
RemainingCapacityInMilliwattHours  : 69689
Status                             : Charging
Utilization                        : 99

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
        $Report = [Windows.Devices.Power.Battery]::AggregateBattery.GetReport() 
        
        If ($Report.Status -ne "NotPresent")
        {
            $pbmax = [convert]::ToDouble($Report.FullChargeCapacityInMilliwattHours)
            $pbvalue = [convert]::ToDouble($Report.RemainingCapacityInMilliwattHours)
            $Utilization = [int][math]::Round( (($pbvalue / $pbmax) *100))
        }
        Else
        {
            [int]$Utilization = 0
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
            }
            $BatteryChargeStatus = (New-Object -TypeName PSObject -Property $Properties)
        }
        Elseif ($Detail -eq $false)
        {
            $Properties = [ordered] @{
            Status = $Report.Status
            Utilization = $Utilization
            }
            $BatteryChargeStatus = (New-Object -TypeName PSObject -Property $Properties)
        }
    }
    End
    {
        $BatteryChargeStatus
    }
}













