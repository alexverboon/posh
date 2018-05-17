function Remove-DefenderHyperVExclusions {
    <#
    .SYNOPSIS
        Remove-DefenderHyperVExclusions
    .DESCRIPTION
        Remove-DefenderHyperVExclusions removes recommended file extensinos, folders
        and processs for the Hyper-V Role from the Defender Exclusion configuration. 

        File type exclusions:
            *.vhd
            *.vhdx
            *.avhd
            *.avhdx
            *.vsv
            *.iso
            *.rct
            *.vmcx
            *.vmrs

        Folder exclusions:
                %ProgramData%\Microsoft\Windows\Hyper-V
                %ProgramFiles%\Hyper-V
                %SystemDrive%\ProgramData\Microsoft\Windows\Hyper-V\Snapshots
                %Public%\Documents\Hyper-V\Virtual Hard Disks

        Process exclusions:
            %systemroot%\System32\Vmms.exe
            %systemroot%\System32\Vmwp.exe

    .EXAMPLE
        PS C:\> Remove-DefenderHyperVExclusions
        
        The above command removes all recommended Hyper-V Defender exclusions.
    .NOTES
        1.0.0 - 16.05.2018 alex verboon

        Recommended exclusions reference:
        https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/configure-server-exclusions-windows-defender-antivirus
    #>

    [cmdletbinding(SupportsShouldProcess)]
    param (
    )

    begin {
        # Check if we're running elevated
        [bool]$elevated = $false
        $elevated = (([Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544")
        If ($elevated -eq $false)
        {
            Write-Error "This script must be run from an elevated process." -ErrorAction Stop
        }

        # File Exclusions
        $Hv_Extensions = @(
            "*.vhd","*.vhdx","*.avhd","*.avhdx","*.vsv","*.iso","*.rct","*.vmcx","*.vmrs"
        )
        # Path Exclusions
        $HV_Path = @(
            "%ProgramData%\Microsoft\Windows\Hyper-V",
            "%ProgramFiles%\Hyper-V",
            "%SystemDrive%\ProgramData\Microsoft\Windows\Hyper-V\Snapshots",
            "%Public%\Documents\Hyper-V\Virtual Hard Disks"
        )

        # Process Exclusions
        $HV_Process = @(
            "%systemroot%\System32\Vmms.exe"
            "%systemroot%\System32\Vmwp.exe"
        )
    }
    
    process {
        if ($PSCmdlet.ShouldProcess("local Defender Configuration" , "Removing Hyper-V Exclusions")) {
            Try{
                Write-Verbose "Removing Defender Exclusions for Hyper-V"
                Add-MpPreference -ExclusionProcess $HV_Process -ExclusionPath $HV_Path -ExclusionExtension $Hv_Extensions 
            }
            Catch{
                Write-Error "An error occoured removnig Defender Exclusions for Hyper-V" -ErrorAction Stop
            }
        }
    }
 
    end {
        If ($PSBoundParameters.Keys -contains "verbose")
        {
            Write-Verbose "Configured Defender Exclusions"
            $WDPref = Get-MpPreference
            Write-Verbose "Excluded Extensions $($WDPref.ExclusionExtension)"
            Write-Verbose "Excluded Paths $($WDPref.ExclusionPath)"
            Write-Verbose "Excluded Paths $($WDPref.ExclusionProcess)"
        }
    }
}