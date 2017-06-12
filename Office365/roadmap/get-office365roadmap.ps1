

Function Get-Office365Roadmap {
    $roadmapfeatures = Invoke-WebRequest -Uri https://roadmap-api.azurewebsites.net/api/features
    $features = $roadmapfeatures.Content
    $rm = ($features) -join "`n" | ConvertFrom-Json 
    $rm
}







   

