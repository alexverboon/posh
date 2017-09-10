
# Install Docker PowerShell Module
# https://github.com/Microsoft/Docker-PowerShell

Register-PSRepository -Name DockerPS-Dev -SourceLocation https://ci.appveyor.com/nuget/docker-powershell-dev
Install-Module Docker -Repository DockerPS-Dev
Import-Module -FullyQualifiedName "C:\Program Files\WindowsPowerShell\Modules\Docker\0.1.0.111\Docker.psd1"


#docker run -it -v c:\users\alexv\Documents\data:/data alex:sift

