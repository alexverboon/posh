
properties {
    $version = $null    
}


Task Lint  -description 'Check scripts for style' {
    write-host "Run PS Script Analyzer"
}

Task Test -description 'Run unit tests' {
    Write-Host "Run Pester"
}

Task Package -description 'Package the module' {
    write-host "Package the module"
    write-host "Package Module $version"
}

Task Deploy -description 'Deploy to the Gallery' {
    write-host "Deploy the package"
}
Task Default -depends Lint,Test




