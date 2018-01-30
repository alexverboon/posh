
# officemktgwebdev.blob.core.windows.net/staging/js/RoadMapScript.js


 
function Convert-ExcelSheetToJson {

<#
.SYNOPSIS
Converts an Excel sheet from a workbook to JSON

.DESCRIPTION
To allow for parsing of Excel Workbooks suitably in PowerShell, this script converts a sheet from a spreadsheet into a JSON file of the same structure as the sheet.

.PARAMETER InputFile
The Excel Workbook to be converted. Can be FileInfo or a String.

.PARAMETER OutputFileName
The path to a JSON file to be created.

.PARAMETER SheetName
The name of the sheet from the Excel Workbook to convert. If only one sheet exists, it will convert that one.

.EXAMPLE
Convert-ExcelSheetToJson -InputFile MyExcelWorkbook.xlsx

.EXAMPLE 
Get-Item MyExcelWorkbook.xlsx | Convert-ExcelSheetToJson -OutputFileName MyConvertedFile.json -SheetName Sheet2

.LINK
https://flamingkeys.com/convert-excel-sheet-json-powershell

.NOTES
Written by: Chris Brown

Find me on:
* My blog: https://flamingkeys.com/
* Github: https://github.com/chrisbrownie

#>
[CmdletBinding()]
Param(
    [Parameter(
        ValueFromPipeline=$true,
        Mandatory=$true
        )]
    [Object]$InputFile,

    [Parameter()]
    [string]$OutputFileName,

    [Parameter()]
    [string]$SheetName
    )

#region prep
# Check what type of file $InputFile is, and update the variable accordingly
if ($InputFile -is "System.IO.FileSystemInfo") {
    $InputFile = $InputFile.FullName.ToString()
}
# Make sure the input file path is fully qualified
$InputFile = [System.IO.Path]::GetFullPath($InputFile)
Write-Verbose "Converting '$InputFile' to JSON"

# If no OutputfileName was specified, make one up
if (-not $OutputFileName) {
    $OutputFileName = [System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $InputFile -Leaf))
    $OutputFileName = Join-Path $pwd ($OutputFileName + ".json")
}
# Make sure the output file path is fully qualified
$OutputFileName = [System.IO.Path]::GetFullPath($OutputFileName)

# Instantiate Excel
$excelApplication = New-Object -ComObject Excel.Application
$excelApplication.DisplayAlerts = $false
$Workbook = $excelApplication.Workbooks.Open($InputFile)

# If SheetName wasn't specified, make sure there's only one sheet
if (-not $SheetName) {
    if ($Workbook.Sheets.Count -eq 1) {
        $SheetName = @($Workbook.Sheets)[0].Name
        Write-Verbose "SheetName was not specified, but only one sheet exists. Converting '$SheetName'"
    } else {
        throw "SheetName was not specified and more than one sheet exists."
    }
} else {
    # If SheetName was specified, make sure the sheet exists
    $theSheet = $Workbook.Sheets | Where-Object {$_.Name -eq $SheetName}
    if (-not $theSheet) {
        throw "Could not locate SheetName '$SheetName' in the workbook"
    }
}
Write-Verbose "Outputting sheet '$SheetName' to '$OutputFileName'"
#endregion prep


# Grab the sheet to work with
$theSheet = $Workbook.Sheets | Where-Object {$_.Name -eq $SheetName}

#region headers
# Get the row of headers
$Headers = @{}
$NumberOfColumns = 0
$FoundHeaderValue = $true
while ($FoundHeaderValue -eq $true) {
    $cellValue = $theSheet.Cells.Item(1, $NumberOfColumns+1).Text
    if ($cellValue.Trim().Length -eq 0) {
        $FoundHeaderValue = $false
    } else {
        $NumberOfColumns++
        $Headers.$NumberOfColumns = $cellValue
    }
}
#endregion headers

# Count the number of rows in use, ignore the header row
$rowsToIterate = $theSheet.UsedRange.Rows.Count

#region rows
$results = @()
foreach ($rowNumber in 2..$rowsToIterate+1) {
    if ($rowNumber -gt 1) {
        $result = @{}
        foreach ($columnNumber in $Headers.GetEnumerator()) {
            $ColumnName = $columnNumber.Value
            $CellValue = $theSheet.Cells.Item($rowNumber, $columnNumber.Name).Value2
            $result.Add($ColumnName,$cellValue)
        }
        $results += $result
    }
}
#endregion rows


$results | ConvertTo-Json | Out-File -Encoding ASCII -FilePath $OutputFileName

Get-Item $OutputFileName

# Close the Workbook
$excelApplication.Workbooks.Close()
# Close Excel
[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excelApplication)

}


Function Convert-ExcelSerialdate
{param ($nExcelSerial)
$x = (Get-Date "1899,12,31").AddDays($nExcelSerial - 1)
return [datetime]$x
}


$rm = (Get-Content C:\dev\posh\Office365\roadmap\Office365RoadMap_Features_10-06-2017.xls.json) -join "`n" | ConvertFrom-Json
$rm | ForEach {$_ | Add-Member -MemberType NoteProperty -Name "Added" -Value (Convert-ExcelSerialdate -nExcelSerial $_.'Added to Roadmap') 
    $_ | Add-Member -MemberType NoteProperty -Name "Modified" -Value (Convert-ExcelSerialdate -nExcelSerial $_.'Last Modified')
}


