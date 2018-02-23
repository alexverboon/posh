

$headers = @{
"Authorization" = "Bearer $accesstoken";
}

$uri = "https://management.azure.com/subscriptions/$subscrID/resourceGroups/$resourcegroupname/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/api/query?api-version=2017-01-01-preview"


  $body = @{
        "query" = $query;
        "timespan" = $Timespan
    } | ConvertTo-Json

$response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Post -ContentType "application/json" -Body $body

 $data = $response.Content | ConvertFrom-Json
   
