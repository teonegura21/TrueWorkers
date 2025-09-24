# Script to fix DTO TypeScript errors

$dtoFiles = @(
    "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\payments\dto\create-wallet.dto.ts",
    "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\payments\dto\create-withdrawal.dto.ts",
    "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\verification\dto\create-verification-request.dto.ts"
)

foreach ($file in $dtoFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Fix userId and walletId to be string instead of number
        $content = $content -replace "userId: number", "userId: string"
        $content = $content -replace "walletId: number", "walletId: string"
        
        $content | Set-Content $file -NoNewline
        Write-Host "Fixed $file"
    }
}

Write-Host "Fixed all DTO files"