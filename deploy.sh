#!/bin/bash
# Production Deployment Script for Mesteri Platform

set -e  # Exit on error

echo "🚀 Starting Mesteri Platform Deployment..."

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "❌ Error: .env.production file not found!"
    echo "Please create .env.production from .env.production.example"
    exit 1
fi

# Load environment variables
export $(cat .env.production | xargs)

echo "📦 Building Docker images..."
docker-compose -f docker-compose.prod.yml build

echo "🔄 Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down

echo "🗄️  Running database migrations..."
docker-compose -f docker-compose.prod.yml run --rm backend npx prisma migrate deploy

echo "🌱 Seeding database (if needed)..."
docker-compose -f docker-compose.prod.yml run --rm backend npm run seed || true

echo "▶️  Starting services..."
docker-compose -f docker-compose.prod.yml up -d

echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service health
echo "🔍 Checking service health..."
docker-compose -f docker-compose.prod.yml ps

# Check backend health
echo "🏥 Checking backend health..."
curl -f http://localhost:3000/api/health || echo "⚠️ Backend health check failed"

# Check frontend health
echo "🏥 Checking frontend health..."
curl -f http://localhost/health || echo "⚠️ Frontend health check failed"

echo "✅ Deployment complete!"
echo ""
echo "📊 Service URLs:"
echo "  - Frontend: http://localhost"
echo "  - Backend API: http://localhost:3000"
echo "  - Database: localhost:5432"
echo ""
echo "📝 View logs with:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "🛑 Stop services with:"
echo "  docker-compose -f docker-compose.prod.yml down"
