
# Source


function Get-ServiceHealthDashboard
{
  [CmdletBinding()]
  [OutputType([PSObject])]
  Param
  (
    [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$false,
    Position=0)]
    [PSCredential]$Credential,

    [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$false,
    Position=1)]
    [switch]$ClearCookie
  )
  Begin
  {
    If(!($PSVersionTable.PSVersion.Major -ge 3)){
      Write-Output "Sorry, PowerShell version 3.0 or above is required!"
      break
    }
    function Get-Error {
      Param(
        [Management.Automation.ErrorRecord]$e
      )
      Begin
      {}
      Process
      {
        $info = [PSCustomObject]@{
          Exception = $e.Exception.Message
          Reason    = $e.CategoryInfo.Reason
          Target    = $e.CategoryInfo.TargetName
          Script    = $e.InvocationInfo.ScriptName
          Line      = $e.InvocationInfo.ScriptLineNumber
          Column    = $e.InvocationInfo.OffsetInLine
        }
      }
      End
      {
        return $info
      }
    }
    If($ClearCookie){
      Remove-Variable -Scope global -Name O365cookie -ErrorAction SilentlyContinue
    }
  }
  Process
  {
    # check if cookie exists and prompt for credentials if not
    If(!($global:O365cookie)){
      Write-Verbose -Message "No O365cookie exist! Need credentials!"
      If(!($Credential)){
        $Credential = $host.ui.PromptForCredential('Office Credentials', 'Please Enter Your Office 365 Credentials','','')
      }
      # create json payload
      $O365jsonPayload = (@{userName=$Credential.username;password=$Credential.GetNetworkCredential().password;} | convertto-json).tostring()
      # retrieve cookie
      try{
        $Registration= invoke-restmethod -contenttype "application/json" -method Post -uri "https://api.admin.microsoftonline.com/shdtenantcommunications.svc/Register" -body $O365jsonPayload -ErrorAction Stop
        $global:O365cookie = $Registration.RegistrationCookie
      }
      catch{
        # get error record
        Get-Error -e $_
        break
      }
      $O365jsonPayload = (@{lastCookie=$global:O365cookie;locale="en-US";preferredEventTypes=@(0,1,2)} | convertto-json).tostring()
    }
    Else{
      Write-Verbose -Message "O365cookie exist! Create JsonPayload"
      # insert cookie into payload
      $O365jsonPayload = (@{lastCookie=$global:O365cookie;locale="en-US";preferredEventTypes=@(0,1)} | convertto-json).tostring()
    }
    try{
      # get events
      $events = (invoke-restmethod -contenttype "application/json" -method Post -uri "https://api.admin.microsoftonline.com/shdtenantcommunications.svc/GetEvents" -body $O365jsonPayload)
    }
    catch{
      # get error record
      Get-Error -e $_
    }
  }
  End
  {
    return $events.Events
  }
}