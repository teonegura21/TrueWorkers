# Script to fix all DTO TypeScript errors

$backendDir = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src"

# Get all DTO files
$dtoFiles = Get-ChildItem -Path $backendDir -Recurse -Filter "*.dto.ts"

foreach ($file in $dtoFiles) {
    Write-Host "Processing $($file.FullName)"
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Fix ID type errors - change number to string for all ID fields
    if ($content -match "userId: number") {
        $content = $content -replace "userId: number", "userId: string"
        $modified = $true
    }
    
    if ($content -match "walletId: number") {
        $content = $content -replace "walletId: number", "walletId: string"
        $modified = $true
    }
    
    if ($content -match "jobId: number") {
        $content = $content -replace "jobId: number", "jobId: string"
        $modified = $true
    }
    
    if ($content -match "projectId: number") {
        $content = $content -replace "projectId: number", "projectId: string"
        $modified = $true
    }
    
    if ($content -match "milestoneId: number") {
        $content = $content -replace "milestoneId: number", "milestoneId: string"
        $modified = $true
    }
    
    if ($content -match "paymentId: number") {
        $content = $content -replace "paymentId: number", "paymentId: string"
        $modified = $true
    }
    
    if ($content -match "reviewId: number") {
        $content = $content -replace "reviewId: number", "reviewId: string"
        $modified = $true
    }
    
    if ($content -match "notificationId: number") {
        $content = $content -replace "notificationId: number", "notificationId: string"
        $modified = $true
    }
    
    if ($content -match "verificationRequestId: number") {
        $content = $content -replace "verificationRequestId: number", "verificationRequestId: string"
        $modified = $true
    }
    
    if ($content -match "documentId: number") {
        $content = $content -replace "documentId: number", "documentId: string"
        $modified = $true
    }
    
    if ($content -match "withdrawalId: number") {
        $content = $content -replace "withdrawalId: number", "withdrawalId: string"
        $modified = $true
    }
    
    # Fix enum issues
    if ($content -match '"pending"') {
        $content = $content -replace '"pending"', 'PaymentStatus.PENDING'
        $modified = $true
    }
    
    if ($content -match '"completed"') {
        $content = $content -replace '"completed"', 'PaymentStatus.COMPLETED'
        $modified = $true
    }
    
    if ($content -match '"failed"') {
        $content = $content -replace '"failed"', 'PaymentStatus.FAILED'
        $modified = $true
    }
    
    # Add enum imports if modified and not already present
    if ($modified -and ($content -match "PaymentStatus\." -or $content -match "WithdrawalStatus\." -or $content -match "VerificationRequestStatus\." -or $content -match "DocumentStatus\.")) {
        if ($content -notmatch "import.*PaymentStatus.*from") {
            $content = "import { PaymentStatus, WithdrawalStatus, VerificationRequestStatus, DocumentStatus } from '@prisma/client';\n" + $content
        }
    }
    
    if ($modified) {
        $content | Set-Content $file.FullName -NoNewline
        Write-Host "Fixed $($file.FullName)"
    }
}

Write-Host "Finished processing all DTO files"