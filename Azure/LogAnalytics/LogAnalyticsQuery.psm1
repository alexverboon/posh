$apiVersion = "2017-01-01-preview"

<#
    .DESCRIPTION
        Invokes a query against the Log Analtyics Query API.

    .EXAMPLE
        Invoke-LogAnaltyicsQuery -WorkspaceName my-workspace -SubscriptionId 0f991b9d-ab0e-4827-9cc7-984d7319017d -ResourceGroup my-resourcegroup
            -Query "union * | limit 1" -CreateObjectView

    .PARAMETER WorkspaceName
        The name of the Workspace to query against.

    .PARAMETER SubscriptionId
        The ID of the Subscription this Workspace belongs to.

    .PARAMETER ResourceGroup
        The name of the Resource Group this Workspace belongs to.

    .PARAMETER Query
        The query to execute.
    
    .PARAMETER Timespan
        The timespan to execute the query against. This should be an ISO 8601 timespan.

    .PARAMETER IncludeTabularView
        If specified, the raw tabular view from the API will be included in the response.

    .PARAMETER IncludeStatistics
        If specified, query statistics will be included in the response.

    .PARAMETER IncludeRender
        If specified, rendering statistics will be included (useful when querying metrics).

    .PARAMETER ServerTimeout
        Specifies the amount of time (in seconds) for the server to wait while executing the query.

    .PARAMETER Environment
        Internal use only.
#>
function Invoke-LogAnalyticsQuery {
param(
    [string]
    [Parameter(Mandatory=$true)]
    $WorkspaceName,

    [guid]
    [Parameter(Mandatory=$true)]
    $SubscriptionId,

    [string]
    [Parameter(Mandatory=$true)]
    $ResourceGroup,

    [string]
    [Parameter(Mandatory=$true)]
    $Query,

    [string]
    $Timespan,

    [switch]
    $IncludeTabularView,

    [switch]
    $IncludeStatistics,

    [switch]
    $IncludeRender,

    [int]
    $ServerTimeout,

    [string]
    [ValidateSet("", "int", "aimon")]
    $Environment = ""
    )

    $ErrorActionPreference = "Stop"

    $accessToken = GetAccessToken

    $armhost = GetArmHost $environment

    $queryParams = @("api-version=$apiVersion")

    $queryParamString = [string]::Join("&", $queryParams)

    $uri = BuildUri $armHost $subscriptionId $resourceGroup $workspaceName $queryParamString

    $body = @{
        "query" = $query;
        "timespan" = $Timespan
    } | ConvertTo-Json

    $headers = GetHeaders $accessToken -IncludeStatistics:$IncludeStatistics -IncludeRender:$IncludeRender -ServerTimeout $ServerTimeout

    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -Body $body -ContentType "application/json" -Headers $headers -Method Post

    if ($response.StatusCode -ne 200 -and $response.StatusCode -ne 204) {
        $statusCode = $response.StatusCode
        $reasonPhrase = $response.StatusDescription
        $message = $response.Content
        throw "Failed to execute query.`nStatus Code: $statusCode`nReason: $reasonPhrase`nMessage: $message"
    }

    $data = $response.Content | ConvertFrom-Json

    $result = New-Object PSObject
    $result | Add-Member -MemberType NoteProperty -Name Response -Value $response

    # In this case, we only need the response member set and we can bail out
    if ($response.StatusCode -eq 204) {
        $result
        return
    }

    $objectView = CreateObjectView $data

    $result | Add-Member -MemberType NoteProperty -Name Results -Value $objectView

    if ($IncludeTabularView) {
        $result | Add-Member -MemberType NoteProperty -Name Tables -Value $data.tables
    }

    if ($IncludeStatistics) {
        $result | Add-Member -MemberType NoteProperty -Name Statistics -Value $data.statistics
    }

    if ($IncludeRender) {
        $result | Add-Member -MemberType NoteProperty -Name Render -Value $data.render
    }

    $result
}

function GetAccessToken {
    $azureCmdlet = get-command -Name Get-AzureRMContext -ErrorAction SilentlyContinue
    if ($azureCmdlet -eq $null)
    {
        $null = Import-Module AzureRM -ErrorAction Stop;
    }
    $AzureContext = & "Get-AzureRmContext" -ErrorAction Stop;
    $authenticationFactory = New-Object -TypeName Microsoft.Azure.Commands.Common.Authentication.Factories.AuthenticationFactory
    if ((Get-Variable -Name PSEdition -ErrorAction Ignore) -and ('Core' -eq $PSEdition)) {
        [Action[string]]$stringAction = {param($s)}
        $serviceCredentials = $authenticationFactory.GetServiceClientCredentials($AzureContext, $stringAction)
    } else {
        $serviceCredentials = $authenticationFactory.GetServiceClientCredentials($AzureContext)
    }

    # We can't get a token directly from the service credentials. Instead, we need to make a dummy message which we will ask
    # the serviceCredentials to add an auth token to, then we can take the token from this message.
    $message = New-Object System.Net.Http.HttpRequestMessage -ArgumentList @([System.Net.Http.HttpMethod]::Get, "http://foobar/")
    $cancellationToken = New-Object System.Threading.CancellationToken
    $null = $serviceCredentials.ProcessHttpRequestAsync($message, $cancellationToken).GetAwaiter().GetResult()
    $accessToken = $message.Headers.GetValues("Authorization").Split(" ")[1] # This comes out in the form "Bearer <token>"

    $accessToken
}

function GetArmHost {
param(
    [string]
    $environment
    )

    switch ($environment) {
        "" {
            $armHost = "management.azure.com"
        }
        "aimon" {
            $armHost = "management.azure.com"
        }
        "int" {
            $armHost = "api-dogfood.resources.windows-int.net"
        }
    }

    $armHost
}

function BuildUri {
param(
    [string]
    $armHost,
    
    [string]
    $subscriptionId,

    [string]
    $resourceGroup,

    [string]
    $workspaceName,

    [string]
    $queryParams
    )

    "https://$armHost/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/" + `
        "microsoft.operationalinsights/workspaces/$workspaceName/api/query?$queryParamString"
}

function GetHeaders {
param(
    [string]
    $AccessToken,

    [switch]
    $IncludeStatistics,

    [switch]
    $IncludeRender,

    [int]
    $ServerTimeout
    )

    $preferString = "response-v1=true"

    if ($IncludeStatistics) {
        $preferString += ",include-statistics=true"
    }

    if ($IncludeRender) {
        $preferString += ",include-render=true"
    }

    if ($ServerTimeout -ne $null) {
        $preferString += ",wait=$ServerTimeout"
    }

    $headers = @{
        "Authorization" = "Bearer $accessToken";
        "prefer" = $preferString;
        "x-ms-app" = "LogAnalyticsQuery.psm1";
        "x-ms-client-request-id" = [Guid]::NewGuid().ToString();
    }

    $headers
}

function CreateObjectView {
param(
    $data
    )

    # Find the number of entries we'll need in this array
    $count = 0
    foreach ($table in $data.Tables) {
        $count += $table.Rows.Count
    }

    $objectView = New-Object object[] $count
    $i = 0;
    foreach ($table in $data.Tables) {
        foreach ($row in $table.Rows) {
            # Create a dictionary of properties
            $properties = @{}
            for ($columnNum=0; $columnNum -lt $table.Columns.Count; $columnNum++) {
                $properties[$table.Columns[$columnNum].name] = $row[$columnNum]
            }
            # Then create a PSObject from it. This seems to be *much* faster than using Add-Member
            $objectView[$i] = (New-Object PSObject -Property $properties)
            $null = $i++
        }
    }

    $objectView
}

Export-ModuleMember Invoke-LogAnalyticsQuery