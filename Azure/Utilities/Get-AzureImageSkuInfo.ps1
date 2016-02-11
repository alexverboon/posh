

function Get-AzureImageSkuInfo
{
<#
.Synopsis
   Get-AzureImageSkuInfo retrieves the available Azure Image SKUs
.DESCRIPTION
   The Get-AzureImageSkuInfo cmdlet retrieves all image SKUs available
   in the offers from all publishers

   Use this function to identify the parameter values required for the 
   Set-AzureRmVMSourceImage cmdlet that is used when creating new Azure VMs
   using New-AzureRmVM.

.OUTPUT
    Publisher
    Offer
    SKU
    ID
    Location
    Version

.EXAMPLE
   Get-AzureImageSkuInfo
.EXAMPLE
    $allvimg = Get-AzureImageSkuInfo
    $allimg | Where-Object {$_.offer -like "windows"}

.NOTES
  Version 1.0, Alex Verboon
#>
[CmdletBinding()]
Param()

Begin{



    # Use the below command to find other valid locations
    #Get-AzureRmResourceProvider -ListAvailable | Select-Object -ExpandProperty ResourceTypes | Select-Object -ExpandProperty Locations -Unique
    Try{
        $Publishers =Get-AzureRmVMImagePublisher -Location "West Europe" 
    }
    Catch{
        # okay looks liek we're not yet connected
        Login-AzureRmAccount
        $Publishers =Get-AzureRmVMImagePublisher -Location "West Europe" 
    }
}

Process{
    $TotalPublishers = $Publishers.count
    $si=1

    ForEach ($pub in $Publishers)
    {
        Write-Progress -Activity "Processing  $si / $TotalPublishers" -Status "Processing $($pub.PublisherName)" -PercentComplete (($si / $TotalPublishers) * 100)
        $offers = Get-AzureRmVMImageOffer -Location "westeurope" -PublisherName $pub.publishername -ErrorAction SilentlyContinue
    
        ForEach ($o in $offers)
        {
            write-verbose "Processing Offer: $($o.Offer)" 
            $sku =  Get-AzureRmVMImageSku -Location "westeurope" -PublisherName $pub.PublisherName -Offer $o.offer -ErrorAction SilentlyContinue
            
            ForEach ($sk in $sku)
            {
                Write-Verbose "Processing SKU: $($sk.skus)" 
                $skuversions = Get-AzureRmVMImage -Location "westeurope" -PublisherName $sk.Publishername -Offer $sk.offer -Skus $sk.skus -ErrorAction SilentlyContinue

                ForEach($skuv in $skuversions)
                {
                    Write-Verbose "Processing SKU version: $($skuv.version)"
                    $props = [ordered]@{
                    Publisher = $sk.publishername
                    Offer = $sk.offer
                    SKU = $sk.skus
                    ID = $sk.id
                    Location = $sk.Location
                    Version =  $skuv.version
                    }
                    $Results += @(New-Object pscustomobject -Property $props)
                }
            } 
        }
         $si++
    }
   
} 

End{
    $Results
}
}


