# Script to fix common TypeScript errors in the backend

$paymentServicePath = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\payments\payments.service.ts"
$verificationServicePath = "c:\Users\TEODO\Desktop\Facultate\Cod C++\AplicatieMesteri\mesteri-platform\backend\src\verification\verification.service.ts"

# Read file contents
$paymentContent = Get-Content $paymentServicePath -Raw
$verificationContent = Get-Content $verificationServicePath -Raw

# Fix payment status enum values
$paymentContent = $paymentContent -replace "'pending'", "PaymentStatus.PENDING"
$paymentContent = $paymentContent -replace "'processing'", "PaymentStatus.PROCESSING"
$paymentContent = $paymentContent -replace "'completed'", "PaymentStatus.COMPLETED"
$paymentContent = $paymentContent -replace "'failed'", "PaymentStatus.FAILED"
$paymentContent = $paymentContent -replace "'cancelled'", "PaymentStatus.CANCELLED"
$paymentContent = $paymentContent -replace "'rejected'", "PaymentStatus.REJECTED"
$paymentContent = $paymentContent -replace "'reported'", "PaymentStatus.REPORTED"
$paymentContent = $paymentContent -replace "'refunded'", "PaymentStatus.REFUNDED"

# Fix verification status enum values
$verificationContent = $verificationContent -replace "'pending'", "VerificationRequestStatus.PENDING"
$verificationContent = $verificationContent -replace "'in_review'", "VerificationRequestStatus.IN_REVIEW"
$verificationContent = $verificationContent -replace "'approved'", "VerificationRequestStatus.APPROVED"
$verificationContent = $verificationContent -replace "'rejected'", "VerificationRequestStatus.REJECTED"
$verificationContent = $verificationContent -replace "'uploaded'", "DocumentStatus.UPLOADED"
$verificationContent = $verificationContent -replace "'verified'", "DocumentStatus.VERIFIED"

# Fix userId parameter types in payment service
$paymentContent = $paymentContent -replace "userId: number", "userId: string"

# Fix userId parameter types in verification service  
$verificationContent = $verificationContent -replace "userId: number", "userId: string"
$verificationContent = $verificationContent -replace "id: number", "id: string"
$verificationContent = $verificationContent -replace "reviewerId: number", "reviewerId: string"
$verificationContent = $verificationContent -replace "documentId: number", "documentId: string"
$verificationContent = $verificationContent -replace "requestId: number", "requestId: string"

# Write the files back
$paymentContent | Set-Content $paymentServicePath -NoNewline
$verificationContent | Set-Content $verificationServicePath -NoNewline

Write-Host "Fixed common TypeScript errors in backend services"