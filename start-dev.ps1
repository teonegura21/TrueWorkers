# Quick Start Script for Mesteri Platform Development (Windows)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Mesteri Platform in Development Mode..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing dependencies..." -ForegroundColor Cyan

# Backend dependencies
Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
Set-Location mesteri-platform\backend
npm install

# Frontend dependencies
Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location ..\app_client
flutter pub get
Set-Location ..\..

Write-Host "🗄️ Setting up database..." -ForegroundColor Cyan
Set-Location mesteri-platform\backend

# Start PostgreSQL with Docker
Write-Host "Starting PostgreSQL..." -ForegroundColor Yellow
docker-compose -f docker-compose.simple.yml up -d postgres

# Wait for PostgreSQL to be ready
Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Run migrations
Write-Host "Running database migrations..." -ForegroundColor Yellow
npx prisma migrate deploy

# Seed database
Write-Host "Seeding database with test data..." -ForegroundColor Yellow
try {
    npm run seed
} catch {
    Write-Host "Seeding completed or skipped" -ForegroundColor Yellow
}

Write-Host "▶️ Starting backend server..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "npm run start:dev" -WorkingDirectory (Get-Location).Path

Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "▶️ Starting Flutter app..." -ForegroundColor Cyan
Set-Location ..\app_client
Start-Process powershell -ArgumentList "-NoExit", "-Command", "flutter run -d chrome" -WorkingDirectory (Get-Location).Path

Set-Location ..\..

Write-Host ""
Write-Host "✅ Mesteri Platform is running!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Service URLs:" -ForegroundColor Cyan
Write-Host "  - Backend API: http://localhost:3000" -ForegroundColor White
Write-Host "  - Database: localhost:5432" -ForegroundColor White
Write-Host "  - Flutter App: Check the Flutter window" -ForegroundColor White
Write-Host ""
Write-Host "🛑 To stop all services:" -ForegroundColor Cyan
Write-Host "  Close the PowerShell windows" -ForegroundColor White
Write-Host "  Then run: cd mesteri-platform\backend; docker-compose -f docker-compose.simple.yml down" -ForegroundColor White
Write-Host ""
