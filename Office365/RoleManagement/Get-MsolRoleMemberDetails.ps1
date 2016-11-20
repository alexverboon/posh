<#
.Synopsis
   Get-MsolRoleMemberDetails
.DESCRIPTION
    This cmdlet lists the members of the Office 365 and Azure Roles
.PARAMETER Role
    This parameter is optional and allows the selection of a specific Office 365 / Azure Role. 
.EXAMPLE
    Get-MsolRoleMemberDetails

    Lists all Roles and users that have the role assigned

.EXAMPLE
    Get-MsolRoleMemberDetails -Role Company_Administrator

    List all usres that are have the specified role assigned
.NOTES
    Version 1.0, 20.09.2016, Alex Verboon
  
#>
function Get-MsolRoleMemberDetails
{
    [CmdletBinding()]
    
    Param()

    DynamicParam {

    $attributes = new-object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = "__AllParameterSets"
    $attributes.Mandatory = $false
    $attributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $attributeCollection.Add($attributes)

    Try
    {
        Get-MsolDomain -ErrorAction Stop > $null
        
    }
    catch 
    {
       write-error "You must call the Connect-MsolService cmdlet before calling any other cmdlets" 
       Throw
    }

    $_Values = ((Get-MsolRole | select-object Name | Sort-object Name).Name) -replace " ","_"

    If ([string]::IsNullOrEmpty($_Values))
    {
        Write-Error "No Roles found, check your connectivity to Office365/Azure"
        Throw
    }

    $ValidateSet = new-object System.Management.Automation.ValidateSetAttribute($_Values)
    $attributeCollection.Add($ValidateSet)
    $Role =  new-object -Type System.Management.Automation.RuntimeDefinedParameter("Role", [string], $attributeCollection)
    $paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $paramDictionary.Add("Role", $Role)
    return $paramDictionary }

Begin
{
    #checking connectivity again, just in case
    Try
    {
        Get-MsolDomain -ErrorAction Stop > $null
        
    }
    catch 
    {
        if ($cred -eq $null) {$cred = Get-Credential $O365Adminuser}
        Write-verbose "Connecting to Office 365"
        Connect-MsolService -Credential $cred
    }

    if ($PSBoundParameters.ContainsKey("Role"))
    {

        $Role = $Role.value -replace "_"," "
        write-verbose "Retrieving Role: members for Role $($Role)"
        $Roles = Get-MsolRole -RoleName "$($Role)"
    }
    Else
    {
        Write-verbose "Retrieving role members for all available roles"
        $Roles = Get-MsolRole | Sort-Object Name
    }
}

Process
{
    $RoleMemberInfo=@()
    ForEach($irole in $Roles)
    {
        write-verbose $irole.Name 
        Write-verbose $irole.ObjectId
        $members= Get-MsolRoleMember -RoleObjectId $irole.ObjectID
        ForEach ($member in $members)
        {
            $Userinfo = Get-MsolUser -ObjectId $member.ObjectId -ErrorAction SilentlyContinue
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name "Role" -Value $irole.Name
            $object | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $member.DisplayName
            $object | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $UserInfo.ObjectId
            $object | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $UserInfo.UserPrincipalName
            $object | Add-Member -MemberType NoteProperty -Name "FirstName" -Value $UserInfo.FirstName
            $object | Add-Member -MemberType NoteProperty -Name "LastName" -Value $UserInfo.LastName
            $object | Add-Member -MemberType NoteProperty -Name "IsLicensed" -Value $UserInfo.IsLicensed
            $RoleMemberInfo += $object
        }
    }

}

End
{
    $RoleMemberInfo
}
}



