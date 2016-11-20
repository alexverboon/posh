<#
.Synopsis
   Get-MsolUserInformation
.DESCRIPTION
   The Get-MsolUserInformation cmdlet provides an easy way to retrieve all users that are a member or guest
   and or are registered in Azure Directory or Active Directory. In addition a new property is added to the 
   output called SynchType which is either set to "InCloud" or "ADSynched". 
.PARAMETER UserPrincipalName
 The user ID of the user to retrieve.
.PARAMETER OutputMode
 Basic or Detailed. Basic only outputs  DisplayName,SynchType,UserPrincipalName
 Detailed outputs all user attributes
.PARAMETER UserType
 Member or Guest
.PARAMETER Directory
 InCloud = in Azure Directory only, ADSynched = registered in Active Directory and Synched to Azure Directory. 

.EXAMPLE
Get-MsolUserInformation -UserPrincipalName alex@foocorp.com -OutputMode Basic

This command shows basic user information for user alex@foocorp.com

.EXAMPLE
Get-MsolUserInformation -OutputMode Detailed

This command retrieves "all" user information for the retrieved users. Use -OutputMode Basic to show the
following information: DisplayName,UserType, SynchType,UserPrincipalName

.EXAMPLE
Get-MsolUserInformation -UserType Member 

This command retrieves all users that are registered on the tenant and therefore their UserType attribute
is set to "Member". Use - Usertype Guest to list all "Guest" users. 

.EXAMPLE
Get-MsolUserInformation -Directory ADSynched

This command retrieves all Active Directory Synched users. 

.EXAMPLE
Get-MsolUserInformation -Directory InCloud

This command lists all users that are registered in Azure Directory only. 

.EXAMPLE
Get-MsolUserInformation -UserType Member -Directory InCloud

This command lists all users that are a member and only registered in AzureDirectory. 

.EXAMPLE
Get-MsolUserInformation -UserType Member -Directory InCloud  | Where-Object {$_.PasswordNeverExpires -eq $rue}

This command lists all Azure Directory users that have the PasswordNeverExpires property set to true. 
.NOTES
Version 1.0, 20.11.2016, Alex Verboon


#>
function Get-MsolUserInformation
{
[CmdLetBinding(DefaultParameterSetName="None")]
    Param
    (
        # The user ID of the user to retrieve.
        [Parameter(ParameterSetName = "OneUser",
        Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true
                   )]
        $UserPrincipalName,

        # The user type can be Member of Guest
        [Parameter(ParameterSetName = "Allusers",
        Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [ValidateSet("Member","Guest")]
        [string]$UserType,

        # The source Directory where the user is created, Azure Directory or Active Directory
        [Parameter(ParameterSetName = "Allusers",
        Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [ValidateSet("InCloud","ADSynched")]
        [string]$Directory,

        # Defines the output mode, Basic or Detailed. 
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true
                   )]
        [ValidateSet("Basic","Detailed")]
        [string]$OutputMode="Detailed"
     )
    Begin
    {
      Try
        {
            Get-MsolDomain -ErrorAction Stop > $null
        }
        catch 
        {
           write-error "You must call the Connect-MsolService cmdlet before calling any other cmdlets" 
           Throw
        }

        if (-not $PSBoundParameters.ContainsKey("UserPrincipalName"))
        {
            if (-not $PSBoundParameters.ContainsKey("UserType"))
            {
                If($Directory -eq "InCloud")
                {
                    $AzureAdUsers = Get-MsolUser | Where-Object {$_.LastDirSyncTime -eq $null}
                }
                Elseif ($Directory -eq "ADSynched")
                {
                    $AzureAdUsers = Get-MsolUser | Where-Object {$_.LastDirSyncTime -ne $null}
                }
                Else
                {
                    $AzureAdUsers = Get-MsolUser
                }
            }
            Else
            {
                if ($Directory -eq "InCloud")
                {    
                     $AzureAdUsers = Get-MsolUser | Where-Object {$_.UserType -eq "$UserType" -and $_.LastDirSyncTime -eq $null}   
                }
                Elseif ($Directory -eq "ADSynched")
                {
                    # This will not return any results as users of type "Guest" aren't synched with AD. 
                    $AzureAdUsers = Get-MsolUser | Where-Object {$_.UserType -eq "$UserType" -and $_.LastDirSyncTime -ne $null}   
                }
                Else
                {
                    $AzureAdUsers = Get-MsolUser | Where-Object {$_.UserType -eq "$UserType"}
                }
            }
        }
        Else
        {
            $AzureAdUsers = Get-MsolUser -UserPrincipalName $UserPrincipalName
        }

    }
    Process
    {

        $AzureAdUsers | foreach {$_ | Add-member -MemberType NoteProperty -Name SynchType `
         -Value ($synchTypevalue = If ($_.LastDirSyncTime -eq $null)
           {
             "InCloud"
           }
           Else
           {
             "ADSynched"
           }
           )
    }       
    
    }
    End
    {
        If ($OutputMode -eq "Basic")
        {
            $output = $AzureAdUsers | Select-Object DisplayName,UserType, SynchType,UserPrincipalName
        }

        If ($OutputMode -eq "Detailed")
        {
            $output = $AzureAdUsers 
        }
    $output
    }
}










