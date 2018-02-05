function Get-MacVendor {
<#
.Synopsis
Resolve MacAddresses To Vendors
.Description
This Function Queries The MacVendors API With Supplied MacAdderess And Returns Manufacturer Information If A Match Is Found
.Parameter MacAddress 
MacAddress To Be Resolved
.Example
Get-MacVendor 
.Example
Get-MacVendor -MacAddress 00:00:00:00:00:00
.Example
Get-DhcpServerv4Lease -ComputerName $ComputerName -ScopeId $ScopeId | Select -ExpandProperty ClientId | Get-MacVendor
#>
		[CmdletBinding()]
		param(
		[Parameter (Mandatory=$true,
                    ValueFromPipeline=$true)]
		[ValidatePattern("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")]
		[string[]]$MacAddress
		)
        process{
		foreach($Mac in $MacAddress){
		try{
				Write-Verbose 'Sending Request to http://api.macvendors.com'
				Invoke-RestMethod -Method Get -Uri http://api.macvendors.com/$Mac -ErrorAction SilentlyContinue | Foreach-object {

					[pscustomobject]@{
						Vendor = $_
						MacAddress = $Mac
					}
				}
			}
		catch{
				Write-Warning -Message "$Mac, $_"
			}
        }
   }
         end{}
    
}
