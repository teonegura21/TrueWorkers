# Script to fix controller TypeScript errors

$backendDir = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src"

# Get all controller files
$controllerFiles = Get-ChildItem -Path $backendDir -Recurse -Filter "*.controller.ts"

foreach ($file in $controllerFiles) {
    Write-Host "Processing $($file.FullName)"
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Fix parameter types in controller methods
    if ($content -match "@Param\('id'\) id: number") {
        $content = $content -replace "@Param\('id'\) id: number", "@Param('id') id: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('userId'\) userId: number") {
        $content = $content -replace "@Param\('userId'\) userId: number", "@Param('userId') userId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('walletId'\) walletId: number") {
        $content = $content -replace "@Param\('walletId'\) walletId: number", "@Param('walletId') walletId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('jobId'\) jobId: number") {
        $content = $content -replace "@Param\('jobId'\) jobId: number", "@Param('jobId') jobId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('projectId'\) projectId: number") {
        $content = $content -replace "@Param\('projectId'\) projectId: number", "@Param('projectId') projectId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('milestoneId'\) milestoneId: number") {
        $content = $content -replace "@Param\('milestoneId'\) milestoneId: number", "@Param('milestoneId') milestoneId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('paymentId'\) paymentId: number") {
        $content = $content -replace "@Param\('paymentId'\) paymentId: number", "@Param('paymentId') paymentId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('withdrawalId'\) withdrawalId: number") {
        $content = $content -replace "@Param\('withdrawalId'\) withdrawalId: number", "@Param('withdrawalId') withdrawalId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('verificationRequestId'\) verificationRequestId: number") {
        $content = $content -replace "@Param\('verificationRequestId'\) verificationRequestId: number", "@Param('verificationRequestId') verificationRequestId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('documentId'\) documentId: number") {
        $content = $content -replace "@Param\('documentId'\) documentId: number", "@Param('documentId') documentId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('reviewId'\) reviewId: number") {
        $content = $content -replace "@Param\('reviewId'\) reviewId: number", "@Param('reviewId') reviewId: string"
        $modified = $true
    }
    
    if ($content -match "@Param\('notificationId'\) notificationId: number") {
        $content = $content -replace "@Param\('notificationId'\) notificationId: number", "@Param('notificationId') notificationId: string"
        $modified = $true
    }
    
    # Fix any remaining enum issues
    if ($content -match '"pending"') {
        $content = $content -replace '"pending"', 'PaymentStatus.PENDING'
        $modified = $true
    }
    
    if ($modified) {
        $content | Set-Content $file.FullName -NoNewline
        Write-Host "Fixed $($file.FullName)"
    }
}

Write-Host "Finished processing all controller files"