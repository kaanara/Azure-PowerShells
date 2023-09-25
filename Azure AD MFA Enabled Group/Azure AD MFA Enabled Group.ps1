# Connect O365
    "Logging in to O365..." 
    Connect-MsolService -Credential (Get-AutomationPSCredential -Name "FOResetMFA")

# Logging in to ExchangeOnline
    "Logging in to ExchangeOnline..." 
    Connect-ExchangeOnline -Credential (Get-AutomationPSCredential -Name "FOResetMFA")

# Listing Users

    "Listing Users" 
    $MFAUsers = Get-MsolUser -All | Where-Object {$_.IsLicensed -eq $true -and $_.StrongAuthenticationMethods.isDefault -eq $true}  
    "MFA enabled users " + $MFAUsers.Count

    $MFAUsersGroup = Get-MsolGroupMember -GroupObjectId "d85c4e68-97a6-402f-bcd7-61fdfc43f3ad" -All
    "MFA Group Users " + $MFAUsersGroup.Count
    
# Find members in the source group that are not in the destination group  
    "Compare for user Add"
    $membersToAdd = $MFAUsers | Where-Object { $_.UserPrincipalName -notin $MFAUsersGroup.EmailAddress }  
    "MFA Group Users Add " + $membersToAdd.count
  
# Find members in the destination group that are not in the source group 
    "Compare for user Remove" 
    $membersToRemove = $MFAUsersGroup | Where-Object { $_.EmailAddress -notin $MFAUsers.UserPrincipalName }  
    "MFA Group Users Remove " + $membersToRemove.count

# Add User to Group - SG - 360 Days Password
    "Add User to Group - SG - 360 Days Password"
    ForEach ($User in $membersToAdd)
    { 
        Add-UnifiedGroupLinks -Identity "SG - 360 Days Password" -LinkType "Members" -Links ($User.UserPrincipalName) -Confirm:$false
        $User.UserPrincipalName
    }
# Remove User to Group - SG - 360 Days Password
    "Remove User to Group - SG - 360 Days Password"
    ForEach ($User in $membersToRemove)
    { 
        Remove-UnifiedGroupLinks -Identity "SG - 360 Days Password" -LinkType "Members" -Links ($User.EmailAddress) -Confirm:$false
        $User.EmailAddress
    }





