#Connect-AzAccount

$filename = (Get-date).Day.ToString() + (Get-date).Month.ToString() + (Get-date).Year.ToString()
$filename = "RGNew" + $filename + ".csv"

if(Test-Path $filename) {
    Remove-Item $filename -Force
}

$subscriptions = Get-AzSubscription

ForEach($sub in $subscriptions)
{
    Select-AzSubscription -SubscriptionId $sub.SubscriptionId
    $group = Get-AzResourceGroup
    ForEach($rg in $group){
        #Get-AzRoleAssignment -ResourceGroupName $rg.ResourceGroupName | select-Object @{l="SubscriptionName";e={$sub.Name}}, @{l="ResourceGroupName";e={$rg.ResourceGroupName}},RoleDefinitionName,Scope,ObjectType,DisplayName,SignInName | Export-Csv $filename -NoTypeInformation -Append -Force
        $Roles= Get-AzRoleAssignment -ResourceGroupName $rg.ResourceGroupName | select-Object @{l="SubscriptionName";e={$sub.Name}}, @{l="ResourceGroupName";e={$rg.ResourceGroupName}},RoleDefinitionName,Scope,ObjectType,DisplayName,SignInName 
    }
}
