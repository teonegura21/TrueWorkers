# Script to fix parseInt calls in controllers

$paymentsController = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\payments\payments.controller.ts"

if (Test-Path $paymentsController) {
    $content = Get-Content $paymentsController -Raw
    
    # Remove parseInt calls since parameters are already strings
    $content = $content -replace "parseInt\(([^)]+)\)", '$1'
    
    $content | Set-Content $paymentsController -NoNewline
    Write-Host "Fixed parseInt calls in payments controller"
}

# Fix other controllers too
$controllerFiles = @(
    "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\verification\verification.controller.ts"
)

foreach ($file in $controllerFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Remove parseInt calls since parameters are already strings
        $content = $content -replace "parseInt\(([^)]+)\)", '$1'
        
        $content | Set-Content $file -NoNewline
        Write-Host "Fixed parseInt calls in $file"
    }
}

Write-Host "Finished fixing parseInt calls"