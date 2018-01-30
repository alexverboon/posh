# playing with modula


$i1 = 4
$im = 18


$pPrivate = 132
$p = [math]::Pow($i1,$pPrivate)
$rp = $p % $im
write-host "Alice: $rp" -ForegroundColor Yellow

$aPrivate = 152
$a = [math]::Pow($i1,$aPrivate)
$ra = $a % $im
Write-Host "Bob" $ra -ForegroundColor Yellow

$rResult = [math]::Pow($ra,$pPrivate) % $im
$aResult = [math]::Pow($rp,$aPrivate) % $im

write-host "$rResult -- $aResult"





