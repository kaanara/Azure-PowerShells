

#Sign into Azure PowerShell with your account

#Connect-AzAccount

#Select a subscription to to monitor with a budget

$subs = Get-AzSubscription

foreach ($sub in $subs) {

    select-AzSubscription -SubscriptionId $sub.Id    

    #Create a monthly budget that sends an email and triggers an Action Group to send a second email. Make sure the StartDate for your monthly budget is set to the first day of the current month. Note that Action Groups can also be used to trigger automation such as Azure Functions or Webhooks.
    $rgs = Get-AzResourceGroup

    foreach ($rg in $rgs) {
        $myOwner = $null
        $AmountUSD = $null        
        $tags = $null
        $myrg = $null

        #get existing budget if any
        $Budget = Get-AzConsumptionBudget -ResourceGroupName $rg.ResourceGroupName        
        
        $tags = Get-AzTag -ResourceId $rg.ResourceId   

        $myrg = $rg.ResourceGroupName
        Write-Host = $myrg 
        #get AmountUSD tag value as integer
        $AmountUSD = $tags.Properties.TagsProperty['AMOUNTUSD']
        Write-Host = $AmountUSD
        #get Owner tag value as single email value or multiple email values split with comma , without any spaces or quotes or delimeters or brackets or paranthesis
        $Owner = $tags.Properties.TagsProperty['OWNER']
        $myOwner = $Owner -split (',')         
        $myOwner += "cloudadmin@ford.com.tr"

        # if there is no existing budget at resource group level
        if (!$Budget) {            

            $BudgetName = "budget-" + $rg.ResourceGroupName + "-001"           
            
            # generate date in YYYY-MM-DD for 10 years period
            $date = Get-Date
            $year = $date.Year
            $month = $date.Month
            $date = $date.AddYears(10)
            $endYear = $date.Year
            $startDate = Get-Date -Year $year -Month $month -Day 1
            $endDate = Get-Date -Year $endYear -Month $month -Day 1

            $startDateStr = ((Get-Date -Year $year -Month $month -Day 1).ToUniversalTime()).ToString("yyyy-MM-ddT00:00:00Z")
            $endDateStr = ((Get-Date -Year $endYear -Month $month -Day 1).ToUniversalTime()).ToString("yyyy-MM-ddT00:00:00Z")

            $body = @{
                "properties" = @{                    
                    "category"      = "Cost"
                    "amount"        = $AmountUSD
                    "timeGrain"     = "Monthly"                    
                    "timePeriod"    = @{
                        "startDate" = $startDateStr
                        "endDate"   = $endDateStr
                    }
                    "notifications" = @{
                        "Actual_GreaterThan_90_Percent"  = @{
                            "enabled"       = $true
                            "operator"      = "GreaterThan"
                            "threshold"     = 90
                            "locale"        = "en-us"
                            "contactEmails" = $myOwner
                            "thresholdType" = "Actual"
                        }
                        "Actual_GreaterThan_100_Percent" = @{
                            "enabled"       = $true
                            "operator"      = "GreaterThan"
                            "threshold"     = 100
                            "locale"        = "en-us"
                            "contactEmails" = $myOwner
                            "thresholdType" = "Actual"
                        }                    
                    }
                }
            }
            $token = (Get-AzAccessToken).token
            $myUri = "https://management.azure.com/subscriptions/" + $sub.Id + "/resourceGroups/" + $rg.ResourceGroupName + "/providers/Microsoft.Consumption/budgets/" + $BudgetName + "?api-version=2021-10-01"
            if ($AmountUSD -gt 0 -and $myOwner[0].Contains("@")) {
                Invoke-RestMethod `
                    -Method Put `
                    -Headers @{"Authorization" = "Bearer $token" } `
                    -ContentType "application/json; charset=utf-8" `
                    -Body (ConvertTo-Json $body -Depth 10) `
                    -Uri $myUri
            }

        }
        else {
            $Budget.Name
            $BudgetName = $Budget.Name
            Set-AzConsumptionBudget -Name $Budget.Name -Amount $AmountUSD
        }
    }
}
