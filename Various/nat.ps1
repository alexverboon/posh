#http://www.thomasmaurer.ch/2015/12/how-to-remote-manage-your-nano-server-using-powershell/
#https://blogs.msdn.microsoft.com/virtual_pc_guy/2008/03/24/using-rras-to-enable-wireless-with-hyper-v/
#https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/user_guide/setup_nat_network
#http://www.thomasmaurer.ch/2015/11/nested-virtualization-in-windows-server-2016-and-windows-10/



#NAT

New-VMSwitch -SwitchName "NATSwitch" -SwitchType Internal
Get-NetAdapter
New-NetIPAddress -IPAddress 192.168.10.1 -PrefixLength 24 -InterfaceIndex 48
New-NetNat -Name MyNATnetwork -InternalIPInterfaceAddressPrefix 192.168.10.0/24

# ps remote nano
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"


#nested virtualization
Set-VMProcessor -VMName SRV2016 -ExposeVirtualizationExtensions $true
Get-VMNetworkAdapter -VMName srv2016 | Set-VMNetworkAdapter -MacAddressSpoofing On


