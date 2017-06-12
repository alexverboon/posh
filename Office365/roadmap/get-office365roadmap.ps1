
Function Get-Office365Roadmap {

<#
.Synopsis
  Get-Office365Roadmap
.DESCRIPTION
   Get-Office365Roadmap retrieves Office 365 information
.EXAMPLE
  Get-Office365Roadmap

  Retrieves the complete Office 365 roadmap information

.EXAMPLE 
 Get-Office365Roadmap -Stats

 Count Name               
----- ----               
  203 In development     
  191 Launched           
   17 Previously released
   61 Rolling out        
    3 Cancelled    

.PARAMETER Stats
 Shows the total number of features grouped by deployment status

#>
    [CmdletBinding()]
    Param(
    [switch]$Stats
    )

    Begin{}
    Process{
        $roadmapfeatures = Invoke-WebRequest -Uri https://roadmap-api.azurewebsites.net/api/features
        $features = $roadmapfeatures.Content
        $rm = ($features) -join "`n" | ConvertFrom-Json 
    }
    
    End{
        If ($Stats -eq $true)
        {
            $rm | Group-Object Status | Select-Object Count,Name
        }
        Else
        {
            $rm
        }
    }
}







   

