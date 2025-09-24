# Script to fix remaining backend errors quickly

$backendDir = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src"

# Fix messages service to remove non-existent fields
$messagesService = "$backendDir\messages\messages.service.ts"
if (Test-Path $messagesService) {
    $content = Get-Content $messagesService -Raw
    
    # Remove problematic imports
    $content = $content -replace ", MessageType, SystemMessageType", ""
    
    # Fix isRead references
    $content = $content -replace "isRead: updateMessageDto\.isRead", "// isRead field removed"
    $content = $content -replace ", isRead: false", ""
    $content = $content -replace "readAt: new Date\(\)", "// readAt field removed"
    $content = $content -replace "content:", "body:"
    
    $content | Set-Content $messagesService -NoNewline
    Write-Host "Fixed messages service"
}

# Fix verification service parameter issues
$verificationService = "$backendDir\verification\verification.service.ts"
if (Test-Path $verificationService) {
    $content = Get-Content $verificationService -Raw
    
    # Fix missing parameters
    $content = $content -replace "reviewerId,", "reviewerId: reviewerId,"
    $content = $content -replace "requestId,", "verificationRequestId: requestId,"
    $content = $content -replace "documentId\)", "documentId: documentId)"
    
    $content | Set-Content $verificationService -NoNewline
    Write-Host "Fixed verification service"
}

Write-Host "Finished fixing backend errors"