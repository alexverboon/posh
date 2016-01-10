




# Check if running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}


$usermode = $env:windir + "\debug\usermode"
#Check if the usermode folder exists
If(!(test-path -Path $usermode))
{
    New-Item -path  $env:windir"\debug" -ItemType Directory -ErrorAction SilentlyContinue | out-null
    New-Item -Path $usermode -ItemType Directory | out-null 
}

#New registry key and value
$regpath =  "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
New-Item -path $regpath -name "Diagnostics" -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics" -Name "GPSvcDebugLevel" -PropertyType DWORD -Value 196610 -ErrorAction SilentlyContinue | Out-Null





