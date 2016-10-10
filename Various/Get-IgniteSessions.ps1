
Function Get-IgniteSessions
{

#https://gallery.technet.microsoft.com/Ignite-2016-Slidedeck-and-296df316
$Ignite2016ContentRssMaxNumber = 1750
$Ignite2016ContentRss = "https://techcommunity.microsoft.com/gxcuf89792/rss/message?board.id=MicrosoftIgniteContent&message.id="
$result = @()
[int]$start = 1
$i = 1

$sw = [System.Diagnostics.Stopwatch]::StartNew()
Write-Progress -Activity "Retrieving Ignite Sessions" -Status "Processing $i of $($Ignite2016ContentRssMaxNumber)" -PercentComplete (($i / $Ignite2016ContentRssMaxNumber) * 100)
 
for ($i = $Start; $i -lt $Ignite2016ContentRssMaxNumber; $i++) {
    $IgniteMessage = Invoke-WebRequest -Uri "$($Ignite2016ContentRss)$i" 
    $IgniteMessage = [xml]$IgniteMessage
    $object = new-object psobject
    Add-Member -InputObject $object -MemberType NoteProperty  -Name Title -Value $IgniteMessage.rss.FirstChild.title
    Add-Member -InputObject $object -MemberType NoteProperty  -Name Link -Value $IgniteMessage.rss.FirstChild.Link
    $result += $object

     if ($sw.Elapsed.TotalMilliseconds -ge 5000)
                     {
                        $curmemusage = "$('{0:n2}' -f ([double](Get-Process -Id $pid).WorkingSet/1MB)) MB"
                        Write-Progress -Activity "Retrieving Ignite Sessions" -Status "Processing $i of $($Ignite2016ContentRssMaxNumber)" -PercentComplete (($i / $Ignite2016ContentRssMaxNumber) * 100)
                        $sw.Reset(); $sw.Start()
                    }
    }
return $result
}

#$session = Get-IgniteSessions

#$isession | Select-Object Title,link | Export-Csv -Path C:\data\dev\posh\Various\ignitesessions.txt -Delimiter ";"


#$savedsesions = Get-Content -Path C:\data\dev\posh\Various\ignitesessions.txt

$sel = $savedsesions | Out-GridView -OutputMode Single 

start-process $sel.Split(";")[1]





