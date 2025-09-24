# Script to fix remaining critical service issues

$paymentsService = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\payments\payments.service.ts"

if (Test-Path $paymentsService) {
    $content = Get-Content $paymentsService -Raw
    
    # Fix the problematic line 122 - replace enum with simple string
    $content = $content -replace "status: WithdrawalStatus\.COMPLETED \| 'in_progress';", "status: 'COMPLETED' | 'in_progress';"
    
    # Fix missing parameters - add walletId parameter to findWithdrawalsByWalletId
    $content = $content -replace "findWithdrawalsByWalletId\(\) \{", "findWithdrawalsByWalletId(walletId: string) {"
    
    # Fix missing parameter - add parameter to removeBankAccount
    $content = $content -replace "removeBankAccount\(userId: string\) \{", "removeBankAccount(userId: string, accountId: string) {"
    
    $content | Set-Content $paymentsService -NoNewline
    Write-Host "Fixed critical issues in payments service"
}

Write-Host "Finished fixing critical service issues"