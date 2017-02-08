#((get-date).ToUniversalTime()).ToString("yyyy-MM-ddThh:mm:ss.fffZ")
#Get-AzureRmOperationalInsightsWorkspace

#$OMSWorkspacename = "AlexVerboonOMS"

#OMS workspace Name
$OMSWorkspacename = "APIDemo"

# identify ResourceGroup Name
$resourcegroupname = (Get-AzureRmOperationalInsightsWorkspace | Where-Object {$_.Name -eq "$OMSWorkspacename"}).ResourceGroupName

# Workspace ID
$customerId = (Get-AzureRmOperationalInsightsWorkspace | Where-Object {$_.Name -eq "$OMSWorkspaceName"}).CustomerId.guid

# Primary Shared Key
$sharedKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $resourcegroupname -Name $OMSWorkspacename).PrimarySharedKey


# Specify the name of the record type that you'll be creating
$LogType = "MyComputers"

# Specify a field with the created time for the records
$TimeStampField = "DateValue"


<#
# Create two records with the same set of properties to create
$json = @"
[{
    "MyComputerName": "Computer20",
    "MyModel": "Latitude1",
    "MyManufacturer": "Dell",
    "MyLocation": "Utrecht"
    
},
{
    "MyComputerName": "Computer21",
    "MyModel": "Latitude2",
    "MyManufacturer": "Dell",
    "MyLocation": "Rotterdam"
},
{
    "MyComputerName": "Computer22",
    "MyModel": "Tecra",
    "MyManufacturer": "Toshiba",
    "MyLocation": "Paris"
}]
"@

#>


# Create two records with the same set of properties to create
$json = @"
[{
    "MyComputerName": "Computer10",
    "MyModel": "T460",
    "MyManufacturer": "Lenovo",
    "MyLocation": "Zurich",
    "DateValue": "2017-02-08T12:13:35.576Z"
},
{
    "MyComputerName": "Computer11",
    "MyModel": "T450",
    "MyManufacturer": "Lenovo",
    "MyLocation": "Amsterdam",
    "DateValue": "2017-02-08T12:13:35.576Z"
},
{
    "MyComputerName": "Computer12",
    "MyModel": "T470",
    "MyManufacturer": "Lenovo",
    "MyLocation": "London",
    "DateValue": "2017-02-08T12:13:35.576Z"
}]
"@




# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}


# Create the function to create and post the request
Function Post-OMSData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -fileName $fileName `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode

}

# Submit the data to the API endpoint
Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType


# Verify that the data is visible in OMS


<#
$dynamicQuery = "* Type=MyComputers_CL"
$result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroupName -WorkspaceName $OMSWorkspacename -Query $dynamicQuery -Top 100
$result.Value | ConvertFrom-Json
#>
