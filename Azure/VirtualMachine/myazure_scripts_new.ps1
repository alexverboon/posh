# https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/
# https://azure.microsoft.com/en-us/blog/azps-1-0/

# https://blogs.msdn.microsoft.com/cloud_solution_architect/2015/05/05/creating-azure-vms-with-arm-powershell-cmdlets/
#  http://trevorsullivan.net/2014/10/02/powershell-build-windows-10-server-technical-preview-vm-in-azure/
#    http://michaelwasham.com/2012/07/13/connecting-windows-azure-virtual-machines-with-powershell/
#    http://azure.microsoft.com/blog/2014/08/27/azure-automation-authenticating-to-azure-using-azure-active-directory/
#    https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-size-specs/

# https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-winrm-windows
# https://github.com/ytechie/AzureResourceVisualizer
# https://www.opsgility.com/blog/2016/01/20/linux-arm/

# https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-ps-create-preconfigure-windows-resource-manager-vms/

# THIS ONE IS GOOD
# https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-create-windows-powershell-resource-manager-template/
# https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-ps-create-preconfigure-windows-resource-manager-vms/
# https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-create-windows-powershell-resource-manager-template/

####################





function xDeploy-MyAzureVM
{
<#
.Synopsis
   Deploys a new Azure virtual machine
   xDeploy-MyAzureVM
.DESCRIPTION
  The xDeploy-MyAzureVM cmdlet provisions a new VM in Azure
.EXAMPLE
   xDeploy-MyAzureVM -VMName VM05
.NOTES
  Version 1.0, Alex Verboon
#>

    [CmdletBinding()]
    Param
    (
        # VM Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$VMName,

        # The Size of the VM Instance. Allowed values are:
        # ExtraSmall,Small,Medium,Large,ExtraLarge,A5,A6,A7,A8,A9,Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=1)]
        [ValidateSet("Basic_A0","Basic_A1","Basic_A2")]
        [string]$InstanceSize,

        # Local Administrator Name
        # Administrator user name. Note the following values are not going to work as Microsoft blocks the 
        # use for security reasons. Admin, Admin1, Administrator. 
        [Parameter(Mandatory=$false,
                  ValueFromPipelineByPropertyName=$true)]
        [string]$LocalAdministrator="Master_Admin", 

        # Local Administrator password
        [Parameter(Mandatory=$false,
                  ValueFromPipelineByPropertyName=$true)]
        [string]$LocalAdministratorPwd = "Access4theAdmin",

        # Domain
        [Parameter(Mandatory=$false,
                  ValueFromPipelineByPropertyName=$true)]
        [string]$JoinDomain = "corp.contoso.com",

        # Domain Join User
        [Parameter(Mandatory=$false,
                  ValueFromPipelineByPropertyName=$true)]
        [string]$DomainUser = "CORP\User1",

        # Domain Join User password
        [Parameter(Mandatory=$false,
                  ValueFromPipelineByPropertyName=$true)]
        [string]$DomainJoinUserPwd = "Access4theAdmin",
        
        # Location
        [Parameter(Mandatory=$false,
                  ValueFromPipelineByPropertyName=$true)]
        [string]$Location = "West Europe"
    )


    Begin
    {

        Try{
        $checkifconnected =Get-AzureRmVMImagePublisher -Location $location 
        }
        Catch{
        # okay looks liek we're not yet connected
        Login-AzureRmAccount
        $checkifconnected =Get-AzureRmVMImagePublisher -Location $location  
        }


        # Begin hardcoded section, adjust so it fits your environment

            # The Azure Subscription Name
            $SubscriptionName = 'Visual Studio Professional with MSDN';
            Select-AzureSubscription -SubscriptionName $SubscriptionName;

            # virtual network
            [string]$VNet = "VN_TestLab"
            [string]$vnetsubnetname = "Default"
            $subnetid = (Get-AzureRmVirtualNetwork | Where-Object{$_.name -eq "$vnet"} | Select-Object -ExpandProperty subnets | Where-Object {$_.Name -eq "$vnetsubnetname"}).id
            $NetworkInterfaceName = "nic11"

            # Get the StorageAccount
            $StorageAccount = Get-AzureRmStorageAccount -Name "sazureverboon01"

            # Define the Resource Group Name
            $ResourceGroupName = (Get-AzureRmResourceGroup -Name "RG_2").ResourceGroupName

            # Local Admin Account
            $SecurePassword = ConvertTo-SecureString "Access4theAdmin" -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ("Master_Admin", $SecurePassword); 

            # Source Image Windows Client
            $SourceImagePublisher = "MicrosoftVisualStudio"
            $SourceImageOffer = "Windows" 
            $SourceImageSku = "10-Enterprise" 
            $SourceImageVersion = "10.0.10242"

            # For Windows Server use the below values for source image
            # "MicrosoftWindowsServer" "WindowsServer" "2012-R2-Datacenter" "latest"
            
        # End of Hardcoded section

        [string]$AzureServiceName = (Get-AzureService).ServiceName
   
        # Windwows Domain
        $uDomain = ($DomainUser -split "\\")[0]
        $DomainJoinUser = ($DomainUser -split "\\")[1]
     } 

    Process
    {

        # VM Configuration settings
        write-host "VM Config Settings"
        $vmconfig = New-AzureRmVMConfig -VMName $VMName -VMSize $InstanceSize 
        $vmconfig | Set-AzureRmVMOperatingSystem -Windows -ComputerName $VMName -EnableAutoUpdate -WinRMHttp -ProvisionVMAgent -Credential $Credential


        # Disk
        $OSDiskName = "OSDDisk_$vmname"
        $OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
        $vmconfig = Set-AzureRmVMOSDisk -VM $vmconfig -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption fromImage 


        # Source Image from Galery
        $vmconfig = Set-AzureRmVMSourceImage -VM $vmconfig -PublisherName $SourceImagePublisher -Offer $SourceImageOffer -Skus $SourceImageSku -Version $SourceImageVersion 


        # Networking
        $publicip = New-AzureRmPublicIpAddress -Name "PubIP_$VMName" -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic 
        $nicnew = New-AzureRmNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -PublicIpAddressId  $publicip.Id -SubnetId $subnetid
        $vmconfig = Add-AzureRmVMNetworkInterface -Id $nicnew.Id -VM $vmconfig 


 
        New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmconfig -Verbose
    }
    End
    {
      
    }
} 



Function xRemove-MyAzureVM
{
<#
.Synopsis
   Removes a Microsoft Azure Virtual Machine
.DESCRIPTION
   The xRemove-MyAzureVM cmdlet deletes a Microsoft Azure Virtual Machine. This process also deletes the
   underlying .vhd files of the disks mounted on that virtual machine. 
.EXAMPLE
   xRemove-MyAzureVM -VMName VM03 
#>
    [CmdletBinding()]
    Param ([Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)] 
    [string]$VMName
    )

    Begin{
        $SubscriptionName = 'Visual Studio Professional with MSDN';
        Select-AzureSubscription -SubscriptionName $SubscriptionName;
        [string]$AzureServiceName = (Get-AzureService).ServiceName
        Write-Output "Azure Service Name: $AzureServiceName"
    }

    Process
    {
        Remove-AzureVM -Name "$VMName" -DeleteVHD -ServiceName "$AzureServiceName" 
    }
    End{}
}



Function xConnect-MyAzureVM
{
<#
.Synopsis
   Starts a Remote Desktop connection to the specified Azure virtual machine
.DESCRIPTION
   The xConnect-MyAzureVM cmdlet downloads and saves a remote desktop connection (RDP) file to a local disk file
   and then launches a remote desktop connection to the specified Azure virtual machine. 
.EXAMPLE
   xConnect-MyAzureVM -VMName VM03
#>
    [CmdletBinding()]
    Param ([Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)] 
    [string]$VMName
    )

    Begin{
        $SubscriptionName = 'Visual Studio Professional with MSDN';
        Select-AzureSubscription -SubscriptionName $SubscriptionName;
        [string]$AzureServiceName = (Get-AzureService).ServiceName
        Write-Output "Azure Service Name: $AzureServiceName"
    }

    Process
    {
        Get-AzureRemoteDesktopFile -ServiceName $AzureServiceName -Name $VMName -Launch
    }
    End{}
}

Function xRemote-MyAzureVM
{
<#
.Synopsis
   Starts a Remote PowerShell session on the specified Azure virtual machine
.DESCRIPTION
   The xRemote-MyAzureVM cmdlet starts a remote PowerShell session on the specified Azure virtual machine.
.EXAMPLE
   xRemote-MyAzureVM -VMName VM03
#>
[CmdletBinding()]
    Param ([Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)] 
    [string]$VMName
    )

    Begin{
        $SubscriptionName = 'Visual Studio Professional with MSDN';
        Select-AzureSubscription -SubscriptionName $SubscriptionName;
        [string]$AzureServiceName = (Get-AzureService).ServiceName
        Write-Output "Azure Service Name: $AzureServiceName"
        $uri = Get-AzureWinRMUri -ServiceName $AzureServiceName -Name $VMName 
        Write-Output "Connection URI: $($uri).Tostring() "
    }
    Process{
        $cred = Get-Credential
        Enter-PSSession -ConnectionUri $uri.Tostring() -Credential $cred
    }
}


Function xStop-MyAzureVM
{
<#
.Synopsis
   Stops an Azure virtual machine
.DESCRIPTION
   The xStop-MyAzureVM stops cmdlet an Azure virtual machine. 
.EXAMPLE
   xStop-MyAzureVM -VMName VM03

   Stops the virtual machine 

.EXAMPLE
   xStop-MyAzureVM -VMName VM03 -StayProvisioned

   Stops the virtual machine, but keeps it provisioned
#>
    [CmdletBinding()]
    Param ([Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)] 
    [string]$VMName,
    [switch]$StayProvisioned
    )

     Begin{
        $SubscriptionName = 'Visual Studio Professional with MSDN';
        Select-AzureSubscription -SubscriptionName $SubscriptionName;
        [string]$AzureServiceName = (Get-AzureService).ServiceName
        Write-Output "Azure Service Name: $AzureServiceName"
    }

    Process
    {
        if ($PSBoundParameters.ContainsKey("StayProvisioned"))
            {
                Stop-AzureVM -Name $VMName -ServiceName $AzureServiceName -StayProvisioned
            }
        Else
            {
                Stop-AzureVM -Name $VMName -ServiceName $AzureServiceName
            }
    }

    End{}

}


Function xStart-MyAzureVM
{
<#
.Synopsis
   Starts an Azure virtual machine
.DESCRIPTION
   The xStart-MyAzureVM starts an Azure virtual machine. 
.EXAMPLE
   xStart-MyAzureVM -VMName VM03

   Starts the virtual machine 
#>

    [CmdletBinding()]
    Param ([Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)] 
    [string]$VMName
    
    )
     Begin{
        $SubscriptionName = 'Visual Studio Professional with MSDN';
        Select-AzureSubscription -SubscriptionName $SubscriptionName;
        [string]$AzureServiceName = (Get-AzureService).ServiceName
        Write-Output "Azure Service Name: $AzureServiceName"
    }

    Process
    {
        Start-AzureVM -Name $VMName -ServiceName $AzureServiceName
    }

    End{}

}
