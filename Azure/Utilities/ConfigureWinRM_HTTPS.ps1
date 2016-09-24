

# Ensure PS remoting is enabled, although this is enabled by default for Azure VMs
Enable-PSRemoting -Force
 
# Create rule in Windows Firewall
New-NetFirewallRule -Name "WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
 
# Create Self Signed certificate and store thumbprint
$thumbprint = (New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
 
# Run WinRM configuration on command line. DNS name set to computer hostname, you may wish to use a FQDN
$cmd = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$env:computername""; CertificateThumbprint=""$thumbprint""}"
cmd.exe /C $cmd