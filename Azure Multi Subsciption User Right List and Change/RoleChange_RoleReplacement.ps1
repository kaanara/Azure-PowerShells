#Connect-AzAccount

$subscriptions = Get-AzSubscription

ForEach($sub in $subscriptions)
{
    Select-AzSubscription -SubscriptionId $sub.SubscriptionId
    $group = Get-AzResourceGroup
    ForEach($rg in $group){
        #Get-AzRoleAssignment -ResourceGroupName $rg.ResourceGroupName | select-Object @{l="SubscriptionName";e={$sub.Name}}, @{l="ResourceGroupName";e={$rg.ResourceGroupName}},RoleDefinitionName,Scope,ObjectType,DisplayName,SignInName | Export-Csv $filename -NoTypeInformation -Append -Force
        $Roles= Get-AzRoleAssignment -ResourceGroupName $rg.ResourceGroupName | select-Object @{l="SubscriptionName";e={$sub.Name}}, @{l="ResourceGroupName";e={$rg.ResourceGroupName}},RoleDefinitionName,Scope,ObjectType,DisplayName,SignInName 
        foreach ($role in $roles)
        {
            if ($role.RoleDefinitionName -eq "Website Contributor")
            {
            #New-AzRoleAssignment -ResourceGroupName $rg.ResourceGroupName -SignInName $role.SignInName -RoleDefinitionName "Monitoring Reader" -AllowDelegation
            #New-AzRoleAssignment -ResourceGroupName $rg.ResourceGroupName -SignInName $role.SignInName -RoleDefinitionName "Website Contributor (FO)" -AllowDelegation
            $role.SignInName
            Remove-AzRoleAssignment -ResourceGroupName $rg.ResourceGroupName -SignInName $role.SignInName -RoleDefinitionName "Website Contributor"
            }
        }
    }
}


                
            