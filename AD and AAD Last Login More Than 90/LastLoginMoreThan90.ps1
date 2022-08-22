#Nessary Modules
#Before Continue RSAT - Active directory domain services and lightweight directory tools must be installed
#Install-Module Microsoft.Graph 
#Install-Module -Name Join-Object 
#Install-Module -Name ImportExcel

Import-Module Microsoft.Graph 
Import-Module Join-Object 
Import-Module ImportExcel

#Authorisation
$ADCredential = Get-Credential
Connect-MgGraph -Scopes "Directory.ReadWrite.All"
Select-MgProfile beta

#GET Data From AD and AAD  
### DO not forget to change server ip address  ###
$AADUsers = Get-MgUser -Filter 'accountEnabled eq true' -All -Property Id,DisplayName,Mail,AssignedLicenses,UserPrincipalName,SignInActivity | Select-Object Id,DisplayName,Mail,UserPrincipalName,SignInActivity -ExpandProperty SignInActivity 
$ADUsers = Get-ADUser -Filter * -Properties GivenName,Name,EmailAddress,UserPrincipalName,LastLogonDate -Server 10.44.47.23 -Credential $ADCredential | Select-Object  GivenName,Name,EmailAddress,UserPrincipalName,LastLogonDate | Sort-Object EmailAddress -Unique 

#AD and AAD Data Export
#$AADUsers | Export-Excel  
#$ADUsers  | Export-Excel 

#AD and AAD Last login not login more than 90 days
$AADUserFilter = $AADUsers | Where-Object {($_.LastSignInDateTime -lt (Get-Date).AddDays(-90)) -and ($_.LastSignInDateTime -ne $null)} | Select-Object DisplayName,Mail,UserPrincipalName,LastSignInDateTime
$ADUserFilter  = $ADUsers | Where-Object {($_.LastLogonDate -lt (Get-Date).AddDays(-90)) -and ($_.EmailAddress -ne $null) -and ($_.UserPrincipalName -ne $null)} | Select-Object  Name,EmailAddress,UserPrincipalName,LastLogonDate

#Combine AD and AAD Opbjects and Export
$AD_AAD_Users = Join-Object -Left $ADUserFilter -LeftJoinProperty EmailAddress -Right $AADUserFilter -RightJoinProperty UserPrincipalName  -Type AllInBoth -ExcludeLeftProperties Mail -Prefix AAD_
$AD_AAD_Users | Export-Excel 

#Close Connection
Disconnect-MgGraph


