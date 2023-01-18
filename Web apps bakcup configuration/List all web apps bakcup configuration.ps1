

$filename = (Get-date).Day.ToString() + (Get-date).Month.ToString() + (Get-date).Year.ToString()
$filename = "RGNew" + $filename + ".csv"

$subscriptions = Get-AzSubscription

ForEach($sub in $subscriptions) 
{
    Select-AzSubscription -SubscriptionId $sub.SubscriptionId
    $webapps = Get-AzWebApp 
    foreach ($webapp in $webapps) 
    {
        Get-AzWebAppBackupConfiguration -Name $webapp.Name -ResourceGroupName $webapp.ResourceGroup | Export-Csv $filename -NoTypeInformation -Append -Force
    } 
}