
function Get-OMSSchemaInfo
{
<#
.Synopsis
   Get-OMSSchemaInfo
.DESCRIPTION
   Get-OMSSchemaInfo
.EXAMPLE
    Get-OMSSchemaInfo -ResourceGroupName mms-weu -WorkSpaceName AlexVerboonOMS

    lists all schema information

.EXAMPLE
    Get-OMSSchemaInfo -ResourceGroupName mms-weu -WorkSpaceName AlexVerboonOMS | Where-Object {$_.OwnerType -like "MyComputers*"}

    lists all schmea information where owner type string starts with "MyComputers" 


#>
[CmdletBinding()]
Param
(
    # The name of the Azure ResourceGroup
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    [string]$ResourceGroupName,
    # The name of the OMS Workspace
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    [string]$WorkSpaceName
)

Begin{

    $schema = Get-AzureRmOperationalInsightsSchema -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkSpaceName
    $schemas = $schema.Value 
}
Process{
    $obj = @()
    ForEach($schema in $schemas)
    {
        $owners = $schema | Select-Object -ExpandProperty OwnerType
        ForEach ($owner in $owners)
        {
            $Properties = @{
            DisplayName = $schema.DisplayName
            Type = $schema.Type
            Indexed = $schema.Indexed
            Stored = $schema.Stored
            Facet = $schema.Facet
            OwnerType = $owner
            }    
            $obj += @(New-Object -TypeName PSCustomObject -Property $Properties)
       }
    }
}

End{
    Write-Output $obj #| Sort-Object OwnerType
    }
}