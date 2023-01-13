
$filename = (Get-date).Day.ToString() + (Get-date).Month.ToString() + (Get-date).Year.ToString()
$filename = "RGNew" + $filename + ".csv"

if(Test-Path $filename) {
    Remove-Item $filename -Force
}

$subscriptions = Get-AzSubscription

ForEach($sub in $subscriptions) {
    Select-AzSubscription -SubscriptionId $sub.SubscriptionId
    Get-AzResourceGroup | Select-Object -ExpandProperty Tags | ConvertTo-Json | ConvertFrom-Json | Export-Csv $filename -NoTypeInformation -Append -Force
}