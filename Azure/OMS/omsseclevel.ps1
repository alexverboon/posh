

$AllIDs = @()
$test = @{}
$secproviders = (Get-winevent -ListProvider *).name

#$secproviders = "Microsoft-Windows-Security-Auditing"
$secproviders = $secproviders + "Microsoft-Windows-AppLocker"

$cnt = 1
ForEach ($provider in $secproviders)
{
   $ids =  (Get-WinEvent -ListProvider $provider  ).events 
   ForEach ($id in $ids)
   {
           $object = [ordered] @{
            Id = $id.Id
            Description = $id.description
            Provider = $provider
            Level = $id.Level.DisplayName
            LogLink = $id.LogLink.DisplayName
           }
           $AllIDs += (New-Object -TypeName PSObject -Property $object)
           $cnt++
   }
}





