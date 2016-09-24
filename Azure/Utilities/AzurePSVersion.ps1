$name='Azure' 
 
if(Get-Module -ListAvailable |  
    Where-Object { $_.name -eq $name })  
{  
    (Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) |  
    Select Version, Name, Author, PowerShellVersion  | Format-List;  
}  
else  
{  
    “The Azure PowerShell module is not installed.” 
}