# Firebase Dependencies Installation Script
# Run this script in the backend directory to install Firebase Admin SDK

Write-Host "🔥 Installing Firebase Admin SDK dependencies..." -ForegroundColor Cyan

# Navigate to backend directory
Set-Location "mesteri-platform\backend"

# Install Firebase Admin SDK
Write-Host "Installing firebase-admin..." -ForegroundColor Yellow
npm install firebase-admin

# Install type definitions (if needed)
Write-Host "Installing @types/node (if not present)..." -ForegroundColor Yellow
npm install --save-dev @types/node

Write-Host "✅ Firebase dependencies installed successfully!" -ForegroundColor Green
Write-Host "📋 Next steps:" -ForegroundColor White
Write-Host "1. Complete Firebase Console setup" -ForegroundColor Gray
Write-Host "2. Download service account keys" -ForegroundColor Gray  
Write-Host "3. Update .env file with Firebase configuration" -ForegroundColor Gray
Write-Host "4. Test Firebase integration" -ForegroundColor Gray