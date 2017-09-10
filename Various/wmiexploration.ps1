
# Dump WMI Classes
$NameSpaces = Get-CimInstance -Namespace root -ClassName __NAMESPACE | Where-Object {$_.Name -eq "CIMV2"} 

ForEach ($ns in $NameSpaces)
{
    write-host "$($ns.name)" -ForegroundColor Green
    $classes = Get-CimClass -Namespace "root/$($ns.name)" 

    ForEach ($cl in $classes)
    {
        if ($cl.CimClassName -like "CIM_*")
        {
            Write-host "skipping CIM__ $($cl.CimClassName)" -ForegroundColor DarkBlue
        }
        Else
        {

        Get-CimInstance -Namespace "root/$($ns.name)" -ClassName "$($cl.CimClassName)" | fl
        write-host "$($ns.name)" -ForegroundColor Cyan
        write-host "$($cl.cimClassname)" -ForegroundColor Yellow
        pause
        }
    }
}
