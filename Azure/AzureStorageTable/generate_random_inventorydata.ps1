

$locations = @("Amsterdam","Paris","Stockholm","London","New York","Seatle","Singapure","Hong Kong","The Hague","Barcelona","Madrid","Stockholm","Rome")

$data = @()
$count = 0
 While ($count -le 100)
 {
    $obj = @{
        RowKey = ([guid]::NewGuid().tostring())
        PartitionKey = "Inventory"
        ComputerName = "Computer" + $count.ToString("000000")
        Location = ($locations)[(Get-Random -Minimum 0 -Maximum $locations.Count )]
        dtDate = [datetime]::UtcNow
    }
    $data += (New-Object -TypeName PSCustomObject -Property $obj)
    $count++
}