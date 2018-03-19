
# https://docs.microsoft.com/en-us/azure/active-directory/active-directory-reporting-api-sign-in-activity-samples

# This script will require the Web Application and permissions setup in Azure Active Directory
$ClientID       = "5c5b39cd-87ab-4a81-84e7-8c0f5799d585"             # Should be a ~35 character string insert your info here
$ClientSecret   = "<>"         # Should be a ~44 character string insert your info here
$loginURL       = "https://login.microsoftonline.com/"
$tenantdomain   = "verboononline.onmicrosoft.com"
$daterange            # For example, contoso.onmicrosoft.com

$7daysago = "{0:s}" -f (get-date).AddDays(-7) + "Z"
# or, AddMinutes(-5)

Write-Output $7daysago

# Get an Oauth 2 access token based on client id, secret and tenant domain
$body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}

$oauth      = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body

if ($oauth.access_token -ne $null) {
$headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}

$url = "https://graph.windows.net/$tenantdomain/activities/signinEvents?api-version=beta&`$filter=signinDateTime ge $7daysago"

$i=0

Do{
    Write-Output "Fetching data using Uri: $url"
    $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url)
    Write-Output "Save the output to a file SigninActivities$i.json"
    Write-Output "---------------------------------------------"
    $myReport.Content | Out-File -FilePath SigninActivities$i.json -Force
    $url = ($myReport.Content | ConvertFrom-Json).'@odata.nextLink'
    $i = $i+1
} while($url -ne $null)

} else {

    Write-Host "ERROR: No Access Token"
}