
# https://kevinmarquette.github.io/2017-05-30-Powershell-your-first-PSScript-repository/


# Local PowerShell Repo
$Path = '\\alve01\PoshRepo'

$repo = @{
    Name = 'MyRepository'
    SourceLocation = $Path
    PublishLocation = $Path
    InstallationPolicy = 'Trusted'
}
Register-PSRepository @repo

$env:PSModulePath

Publish-Module -Name GroupPolicyxTended -Repository "MyRepository" 





