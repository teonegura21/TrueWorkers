# Production Deployment Script for Mesteri Platform (Windows)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Mesteri Platform Deployment..." -ForegroundColor Green

# Check if .env.production exists
if (-Not (Test-Path ".env.production")) {
    Write-Host "❌ Error: .env.production file not found!" -ForegroundColor Red
    Write-Host "Please create .env.production from .env.production.example" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Building Docker images..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml build

Write-Host "🔄 Stopping existing containers..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml down

Write-Host "🗄️ Running database migrations..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml run --rm backend npx prisma migrate deploy

Write-Host "🌱 Seeding database (if needed)..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml run --rm backend npm run seed

Write-Host "▶️ Starting services..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml up -d

Write-Host "⏳ Waiting for services to be healthy..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Check service health
Write-Host "🔍 Checking service health..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml ps

# Check backend health
Write-Host "🏥 Checking backend health..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Backend is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Backend health check failed" -ForegroundColor Yellow
}

# Check frontend health
Write-Host "🏥 Checking frontend health..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost/health" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Frontend is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Frontend health check failed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Service URLs:" -ForegroundColor Cyan
Write-Host "  - Frontend: http://localhost" -ForegroundColor White
Write-Host "  - Backend API: http://localhost:3000" -ForegroundColor White
Write-Host "  - Database: localhost:5432" -ForegroundColor White
Write-Host ""
Write-Host "📝 View logs with:" -ForegroundColor Cyan
Write-Host "  docker-compose -f docker-compose.prod.yml logs -f" -ForegroundColor White
Write-Host ""
Write-Host "🛑 Stop services with:" -ForegroundColor Cyan
Write-Host "  docker-compose -f docker-compose.prod.yml down" -ForegroundColor White
