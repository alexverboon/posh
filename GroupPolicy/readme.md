# The GroupPolicyXtended Module

This module contains cmdlets for Group Policy management

## Installation
In order to install the module, open a PowerShell prompt and paste the following line (triple-click to select all of it), then press [ENTER].

`$wc=New-Object System.Net.WebClient;$wc.UseDefaultCredentials=$true;iex $wc.DownloadString("https://raw.githubusercontent.com/alexverboon/posh/master/GroupPolicy/install-GroupPolicyXtended.ps1")`

The module is installed into C:\Users\<username>\Documents\WindowsPowerShell\Modules\GroupPolicyXtended


## Update
Run Update-GroupPolicyXtended to update the module to the latest version

## Topics

### Get-GPEventByCorrelationID
    This function retrieves Group Policy event log entries filtered by Correlation ID from the specified computer

###Get-GPProcessingtime   
   The Get-GPProcessingtime cmdlet gets Group Policy processing time for the user and computer related 
   Group Policies that are processed on the specified computer(s). 

###Set-GPLogging
    The Set-GPLogging cmdlet enables or disables Group Policy Service or Group Policy Preferences
    logging. 
    
###Get-GPLogging
    The Get-GPLogging cmdlet retrieves information about the Group Policy Service Debug
    or Group Policy Preference logging configuration set on a computer. 

###Update-GroupPolicyXtended 
Run this cmdlet to update the module to the latest version. 


