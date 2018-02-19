Function Extract-ManagementPackScrpts
{
<#
.SYNOPSIS
    Extract-ManagementPackScrpts
.DESCRIPTION
    The Extract-ManagementPackScrpts cmdlet parses through the 
    ManagementPack xml definition files and extracts Code that
    is embedded within the 'ScriptBody" Node. 
.PARAMETER ScriptOutFldr
    Location where found script content is saved to. 

.EXAMPLE
    Extract-ManagementPackScrpts

    The above command parses through all Management Pack
    XML definition files located in the folder
    C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Management Packs
    and saves the found script content to C:\TEMP\ScrOut

.NOTES
    The extracted scripts will not run because there's still
    some HTML code within the scripts, but you can popen the 
    scripts in VSCODE to study the content. 
#>


[CmdletBinding()]
Param(
# Output folder to save found script content
[string]$ScriptOutFldr = "C:\TEMP\ScrOut"
)

# Location of OMS Management Packs
$ManagementPackFldr = "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Management Packs"



If ((Test-Path "$ManagementPackFldr") -eq $false)
{
    Write-Warning "Management Pack Folder: $ManagementPackFldr not found"
    Throw
}


If ((Test-Path "$ScriptOutFldr") -eq $false )
{
    New-Item "$ScriptOutFldr" -ItemType Directory
}


$files = Get-ChildItem "$ManagementPackFldr\*.xml" -Recurse
$Result = @()

foreach ( $file in $files )
{
    Write-verbose "Processing $($file.Name)" 
    [System.Xml.XmlDocument]$doc = new-object System.Xml.XmlDocument;
    $doc.set_PreserveWhiteSpace( $true );
    $doc.Load( $file );
    $root = $doc.get_DocumentElement();
    $xml = $root.get_outerXml()
    $xml = '<?xml version="1.0" encoding="utf-8"?>' + $xml
    $newFile = "$env:temp\$($file.Name)" + ".new"

    Set-Content -Encoding UTF8 $newFile $xml 
 
        # find ScriptBody Nodes
        $scripts = Select-Xml -Path $newFile -XPath "//ScriptBody"
        $scount=1
        ForEach ($script in $scripts)
        {
            # ScriptBody
            $ScriptBody = $script.Node.InnerXml
            If ($ScriptBody -ne "`$Config/ScriptBody$")
            {
                $object = @{
                ManagementPack = $File.Name
                ScriptBody = $ScriptBody
                }
            $Result += (New-Object -TypeName PSObject -Property $object)
            
            $object.ScriptBody | Out-File -FilePath ("$ScriptOutFldr\$($file.name)_$scount"+".ps1") -Encoding unicode -NoNewline
            $scount++
            }
        }
    Remove-Item -Path $newFile -Force
}

Write-output "Scripts found in the following Management Packs"
write-output ""

$Result | Select-Object ManagementPack

write-output ""
Write-output "Script sources saved to $ScriptOutFldr" 

}
