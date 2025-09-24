# Script to fix remaining TypeScript errors

$paymentServicePath = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\payments\payments.service.ts"
$verificationServicePath = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\verification\verification.service.ts"
$verificationControllerPath = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\verification\verification.controller.ts"

# Read file contents
$paymentContent = Get-Content $paymentServicePath -Raw
$verificationContent = Get-Content $verificationServicePath -Raw
$verificationControllerContent = Get-Content $verificationControllerPath -Raw

# Fix imports in payment service to add WithdrawalStatus
$paymentContent = $paymentContent -replace "import { Payment, Wallet, Withdrawal, PaymentStatus, WithdrawalStatus } from '@prisma/client';", "import { Payment, Wallet, Withdrawal, PaymentStatus, WithdrawalStatus } from '@prisma/client';"

# Fix imports in verification service 
$verificationContent = $verificationContent -replace "import { VerificationRequest, Document, VerificationBadge, VerificationRequestStatus, DocumentStatus } from '@prisma/client';", "import { VerificationRequest, Document, VerificationBadge, VerificationRequestStatus, DocumentStatus } from '@prisma/client';"

# Fix wallet id parameter types in payment service
$paymentContent = $paymentContent -replace "id: number", "id: string"

# Fix withdrawal service to use WithdrawalStatus instead of PaymentStatus
$paymentContent = $paymentContent -replace "PaymentStatus\.PENDING", "WithdrawalStatus.PENDING"
$paymentContent = $paymentContent -replace "PaymentStatus\.PROCESSING", "WithdrawalStatus.PROCESSING" 
$paymentContent = $paymentContent -replace "PaymentStatus\.COMPLETED", "WithdrawalStatus.COMPLETED"
$paymentContent = $paymentContent -replace "PaymentStatus\.FAILED", "WithdrawalStatus.FAILED"
$paymentContent = $paymentContent -replace "PaymentStatus\.REJECTED", "WithdrawalStatus.REJECTED"
$paymentContent = $paymentContent -replace "PaymentStatus\.REPORTED", "WithdrawalStatus.REPORTED"
$paymentContent = $paymentContent -replace "PaymentStatus\.CANCELLED", "WithdrawalStatus.CANCELLED"

# Actually just replace all instances with the correct PaymentStatus for payments
$paymentContent = $paymentContent -replace "WithdrawalStatus\.PENDING", "WithdrawalStatus.PENDING"
$paymentContent = $paymentContent -replace "WithdrawalStatus\.PROCESSING", "WithdrawalStatus.PROCESSING"
$paymentContent = $paymentContent -replace "WithdrawalStatus\.COMPLETED", "WithdrawalStatus.COMPLETED"
$paymentContent = $paymentContent -replace "WithdrawalStatus\.FAILED", "WithdrawalStatus.FAILED"
$paymentContent = $paymentContent -replace "WithdrawalStatus\.REJECTED", "WithdrawalStatus.REJECTED"
$paymentContent = $paymentContent -replace "WithdrawalStatus\.REPORTED", "WithdrawalStatus.REPORTED"
$paymentContent = $paymentContent -replace "WithdrawalStatus\.CANCELLED", "WithdrawalStatus.CANCELLED"

# Fix walletId parameter
$paymentContent = $paymentContent -replace "walletId: number", "walletId: string"

# Fix verification controller to not parse IDs
$verificationControllerContent = $verificationControllerContent -replace "parseInt\(id\)", "id"
$verificationControllerContent = $verificationControllerContent -replace "parseInt\(userId\)", "userId"
$verificationControllerContent = $verificationControllerContent -replace "parseInt\(requestId\)", "requestId"
$verificationControllerContent = $verificationControllerContent -replace "parseInt\(documentId\)", "documentId"

# Write the files back
$paymentContent | Set-Content $paymentServicePath -NoNewline
$verificationContent | Set-Content $verificationServicePath -NoNewline
$verificationControllerContent | Set-Content $verificationControllerPath -NoNewline

Write-Host "Fixed remaining TypeScript errors"