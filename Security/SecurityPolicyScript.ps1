#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------
# This script pulls securty policy settings for this machine and parse it to objects with the following members:
# 	SectionName
# 	SettingName
# 	SettingValue
# return the list of these objects

#random output file name for each run
$tmpFileGuid = [guid]::NewGuid()
$outputFilePath = "$tmpFileGuid.inf"

# "Start running get security policy command"
secedit  /export /areas USER_RIGHTS /cfg $outputFilePath >  $null


if($LASTEXITCODE -ne 0){
	throw [System.InvalidOperationException] "Secedt failed with error code $LASTEXITCODE"
}

# "Pulling content from output file: $outputFilePath"
$content = Get-Content $outputFilePath



#retry 3 times to delete the temporary output file (with 5 seconds sleep between retries). 
# If failed to delete - throw exception and fail the run.
$retryCount = 3
for($i=1; $i -le $retryCount; $i++)
{
	# "Removing output file: $outputFilePath"
	Remove-Item $outputFilePath
	
	if(Test-Path $outputFilePath){
		if($i -eq $retryCount){
			throw [System.InvalidOperationException] "Failed to delete file $outputFilePath after $retryCount retries"
		}		
		Start-Sleep -s 5
	}
	else{
		break
	}
}

$result = @()
$currentPolicyGroup  = ""

# "Start parsing content"
foreach ($line in $content){
	$securityPolicyObj = new-object psobject
	
	if($line.StartsWith("[")){
		$line=$line.TrimStart("[")
		$line=$line.TrimEnd("]")
		$currentPolicyGroup = $line
	}
	else{
		$splittedSetting = $line.Split("=")
		if($splittedSetting.length -ne 2){
			throw "Security settings output is not in the correct format"
		}
		$policyKey = [guid]::NewGuid()
		$settingName = $splittedSetting[0].TrimEnd(" ")
		$settingValue = $splittedSetting[1].TrimStart(" ")
		Add-Member -InputObject $securityPolicyObj -MemberType NoteProperty  -Name SectionName -Value $currentPolicyGroup
		Add-Member -InputObject $securityPolicyObj -MemberType NoteProperty  -Name SettingName -Value $settingName
		Add-Member -InputObject $securityPolicyObj -MemberType NoteProperty  -Name SettingValue -Value $settingValue
		Add-Member -InputObject $securityPolicyObj -MemberType NoteProperty  -Name PolicyKey -Value $policyKey
		$result += $securityPolicyObj
	}
}

# "Finished getting and parsing security policy"
#return $result
$result | fl
