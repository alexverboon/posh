# A few PowerShell snippets and notes I put together while playing with ELK


Function Get-ELKIndexPattern
{
    $indp = Invoke-WebRequest -Uri http://localhost:9200/_cat/indices?v
    $indp.Content

}

Function Delete-ELKWinlogbeatdocs
{
    Write-Warning "This will delete all previously uploaded log data to WinLogBeat" 
    PAUSE
    Invoke-WebRequest -Uri 'http://localhost:9200/winlogbeat-*' -Method Delete
}

# loading index template
#https://www.elastic.co/guide/en/beats/winlogbeat/current/winlogbeat-template.html
# nvoke-WebRequest -Method Put -InFile "C:\Data\winlogbeat-5.2.2-windows-x86_64\winlogbeat.template.json" -Uri http://localhost:9200/_template/winlogbeat?pretty



Function Install-WinLogBeatService{

# delete service if it already exists
if (Get-Service winlogbeat -ErrorAction SilentlyContinue) {
  $service = Get-WmiObject -Class Win32_Service -Filter "name='winlogbeat'"
  $service.StopService()
  Start-Sleep -s 1
  $service.delete()
}
$workdir = Split-Path $MyInvocation.MyCommand.Path

# create new service
New-Service -name winlogbeat `
  -displayName winlogbeat `
  -binaryPathName "`"$workdir\\winlogbeat.exe`" -c `"$workdir\\winlogbeat.yml`" -path.home `"$workdir`" -path.data `"C:\\ProgramData\\winlogbeat`""
}



<# Web Resources

http://robwillis.info/2016/05/installing-elasticsearch-logstash-and-kibana-elk-on-windows-server-2012-r2/



#>

I