#Connect-AzAccount

$budgets = Import-Csv -Path C:\Users\kara.FORDOTOSAN\Desktop\Budget.csv

foreach ($budget in $budgets){


    $budget.ResourceGroup

    $replacedTags = @{"Budget"=$budget.Budget; "Amountusd"=$budget.Amountusd;}

    Update-AzTag -ResourceId $budget.ResourceId -Tag $replacedTags -Operation Merge

}



