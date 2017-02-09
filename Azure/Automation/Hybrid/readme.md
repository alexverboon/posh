# Azure Hybrid Worker Management

## Add-HybridWorker.ps1
The Add-HybridWorker cmdlet registers a system as a Hybrid worker, this
script requires that the OMS Agent is already installed on the system. 

## Remove-HybridWorker.ps1
The Remove-HybridWorker cmdlet removes a system as a Hybrid worker. This
script requires that the OMS Agent is already installed on the system. 

## New-OnPremiseHybridWorker
Script Source: https://www.powershellgallery.com/packages/New-OnPremiseHybridWorker/1.1/DisplayScript

This Azure/OMS Automation runbook onboards a local machine as a hybrid worker

This script does not require that the OMS Agent is already installed. The script
will download and install the agent prior registering it as a hybrid worker. 

Important: Ensure that you provide correct Automation account parameters, otherwise
the script will create a new one. 



