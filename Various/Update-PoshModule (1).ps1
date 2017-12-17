function Update-PoshModule
{
<#
.Synopsis
   Update-PSModule

.DESCRIPTION
   The Update-PoshModule cmdlet checks whether a newwer PowerShell Module version is available and when found
   installs it. Optionally previous versions of the Module can be removed. 

.PARAMETER Repository
   The name of the Repository if no value is provided the PSGallery repository is used. 

.PARAMETER ModulePrefix
   The prefix or full PowerShell Module Name
.PARAMETER RemovePreviousVersions
   When specified all older versions of the Module are removed from the local system. 
.PARAMETER SkipPublisherCheck
   Allows the installation of unsigned modules
.PARAMETER Scope
   Specifies the installation scope of the module. The acceptable values for this 
   parameter are: AllUsers and CurrentUser.
        
   The AllUsers scope lets modules be installed in a location that is accessible to all 
   users of the computer, that is, %systemdrive%:\ProgramFiles\WindowsPowerShell\Modules.
        
   The CurrentUser scope lets modules be installed only to 
   $home\Documents\WindowsPowerShell\Modules, so that the module is available only to 
   the current user.
.PARAMETER ReturnOutput
   When specifid the cmdlet returns an object containing all the collected module information. 

.EXAMPLE
   Update-PoshModule -Repository PSGAllery -ModulePrefix Pester -SkipPublisherCheck -Scope CurrentUser

   The above command checks whether there is a new Module version available for Pester in the Public
   PowerShell Repository and installs it

.EXMAPLE
   Update-PoshModule -ModulePrefix Pester -RemovePreviousVersions -SkipPublisherCheck -Scope CurrentUser

   The above command checks whether there is a new moduole version available for Pester, installs it
   and removes older local installed versions. 

.NOTES
   v1, 17.12.2017, alex verboon
#>

    [CmdletBinding(SupportsShouldProcess=$true)]
    Param
    (
        # PowerShell Module Repository name
        [Parameter(Mandatory=$false)]
        [string]$Repository = "PSGAllery",
        # Prefix or entire PoweShell module name
        [Parameter(Mandatory=$true)]
        [string]$ModulePrefix,
        # When enabled, removes previous module versions
        [switch]$RemovePreviousVersions,
        # allow instalaltion of unsigned modules
        [switch]$SkipPublisherCheck,
        # Installation Scope
        [Parameter()]
        [validateset("CurrentUser","AllUsers")]
        [string]
        $Scope = "AllUsers",
        [switch]$ReturnOutput
    )
    
    Begin
    {
        # handle SkipPublishercheck to install unsigned modules
        $ParamSkipPublisherCheck = @{
            SkipPublisherCheck = if ($PSBoundParameters.SkipPublisherCheck -eq $true) { $true } else { $false };
        }

        # define the scope to install modules. 
       If ($PSBoundParameters["Scope"])
       {
            $ScopeParam = $Scope
            Write-Verbose "Scope: $ScopeParam"
       }
       Else
       {
            $ScopeParam =  "AllUsers"
            Write-Verbose "Scope: $ScopeParam"
       }

       # PowerShell Module locations for CurrentUser and AllUsers
       $script:ProgramFilesPSPath = Microsoft.PowerShell.Management\Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell"
       $script:MyDocumentsPSPath = Microsoft.PowerShell.Management\Join-Path -Path $HOME -ChildPath 'Documents\WindowsPowerShell'
       $script:ProgramFilesModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $script:ProgramFilesPSPath -ChildPath "Modules"
       $script:MyDocumentsModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $script:MyDocumentsPSPath -ChildPath "Modules"

       


        $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
        $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
        $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
        $script:IsRunningAsElevated = $prp.IsInRole($adm)

        if(-not ($script:IsRunningAsElevated -eq $true) -and ($Scope -ne "CurrentUser"))
        {
            # Throw an error when Install-Module is used as a non-admin user and '-Scope CurrentUser' is not specified
            Write-Error "You must run PowerShell in elevated mode when installing for AllUsers or use the -Scope CurrentUser parameter"
            Throw 
        }

        Write-Verbose "Checking Repository: $Repository"
        $repcheck = Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue
        if ($repcheck.name -eq "$Repository")
        {
            Write-Verbose "Reppsitory $Repository found"
        }
        Else
        {
        Write-Warning "Unable to find the PowerShell Repository $Repository"
        Throw
        }


        Write-Output "Searching for Modules: $($ModulePrefix)..."
        $currentmodulesAll = Get-Module -ListAvailable | Where-Object {$_.name -like "$ModulePrefix*"} | Sort-Object -Unique 
        $currentmodules = $currentmodulesAll | Select-Object * | Where-Object {$_.Path -like "$script:MyDocumentsModulesPath*" -or $_.Path -like "$script:ProgramFilesModulesPath*"}
        

        If ($currentmodules.Count -ne 0)
        {
            $RepoCompare = @()
            ForEach ($mod in $currentmodules)
            {
              write-verbose "Searching for Module $($mod.name)"
              $latestrepo = Find-module -Name "$($mod.Name)" -Repository $Repository -ErrorAction Continue
              
              If ([string]::IsNullOrEmpty($latestrepo))
              {
                Write-Warning "Module $($mod.name) not found"
                $prop = @{
                "version" = "0"
                "name" = "unkonwn"
                }
              $latestrepo = New-Object -TypeName PSObject -Property $prop                
              }

                
              $object = @{
              LocalModuleType = $mod.ModuleType
              LocalVersion = $mod.version
              LocalName = $mod.Name
              LocalPath = $mod.path
              RemoteVersion = $latestrepo.version
              RemoteName = $latestrepo.Name
              }
              $RepoCompare += (New-Object PSObject -Property $object)
            }
        }
        Else
        {
            Write-Warning "No PowerShell Modules found that match the Module Prefix or Name: $ModulePrefix"
            Break
        }
    }
    Process
    {
        ForEach ($entry in $RepoCompare)
        {
            Write-Output "----------------------------------------------------"
            write-output "PowerShell Module : $($entry.LocalName)"
            Write-Output "Installed version : $($entry.LocalVersion)"
            Write-Output "ModulePath        : $($entry.localpath)"
            Write-Output "Latest version    : $($entry.RemoteVersion)"

            If ([System.Version]"$($entry.LocalVersion)" -eq [system.version]"$($entry.RemoteVersion)" -eq $true)
            {
                Write-host "Latest version already installed" -ForegroundColor Green
            }
            Elseif ([System.Version]"$($entry.LocalVersion)" -gt [system.version]"$($entry.RemoteVersion)" -eq $true)
            {
                Write-host "A newer version is installed locally" -ForegroundColor Yellow
            }
            ElseIf ([System.Version]"$($entry.LocalVersion)" -lt [system.version]"$($entry.RemoteVersion)" -eq $true)
            {
                Write-host "A newer version is available" -ForegroundColor Magenta

                If ($PScmdlet.ShouldProcess("Installing latest version of PowerShell Module: $($entry.LocalName)"))
                {
                    Try{
                        Write-output "Installing latest version"
                        Find-Module "$($entry.LocalName)" -Repository $Repository | Install-Module -Force @ParamSkipPublisherCheck -Scope "$ScopeParam"
                    }
                    Catch{
                        Write-Warning "Unable to install latest version of PowerShell Module $($entry.LocalName)"
                        Break
                    }
                }
            }
        #}

        # ----------------------------------------------------------------------------------------- #
        # Remove Previous versions
        # ----------------------------------------------------------------------------------------- #
        If ($PSBoundParameters["RemovePreviousVersions"])
        {
            if ($PSBoundParameters['whatif'])
            {
                $LatestVersion = $entry.remoteversion
            }
            Else
            {
                $LatestVersion = ((Get-Module -Name "$($entry.LocalName)" -ListAvailable | Sort-Object $_.version)[0]).Version
            }
            Write-Verbose "Most recent local version:  $($LatestVersion)"
            $allversions = Get-Module -Name "$($entry.LocalName)" -ListAvailable | Where-Object {$_.Path -like "$script:MyDocumentsModulesPath*" -or $_.Path -like "$script:ProgramFilesModulesPath*"}

            ForEach ($version in $allversions)
            {
                If ($version.Version -ne $LatestVersion)
                {
                    If ($PScmdlet.ShouldProcess("Removing lersion $($version.version) of PowerShell Module: $($entry.LocalName) from $($version.path)" ))
                    {
                        Try{
                            $ModulePsd = $version.Path
                            $ModulePath = Split-Path $version.Path -Parent
                            Write-Output "Removing Module $ModulePath"
                            Remove-Module -FullyQualifiedName "$ModulePsd" -Force -ErrorAction SilentlyContinue
                            Write-Output "Deleting Module Folder: $ModulePath"
                            Remove-item -Path $ModulePath -Recurse -Force
                        }
                        Catch
                        {
                            Write-Warning "Unable to remove PowerShell Module "$($entry.LocalName)" version "$($version.version)""
                        }
                    }
                }
            }
        }
        # ----------------------------------------------------------------------------------------- #
    }   
}

End
    {
    If ($PSBoundParameters["ReturnOutput"])
    {$RepoCompare}
}
}


