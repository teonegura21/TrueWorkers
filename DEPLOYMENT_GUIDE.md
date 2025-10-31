# Mesteri Platform - Deployment Guide

Complete guide for deploying the Mesteri Platform to production.

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Local Development](#local-development)
- [Production Deployment](#production-deployment)
- [Post-Deployment](#post-deployment)
- [Monitoring & Maintenance](#monitoring--maintenance)

## 🔧 Prerequisites

### Required Software
- Docker Desktop (latest version)
- Docker Compose v2.0+
- Git
- Node.js 20+ (for local development)
- Flutter 3.9+ (for local app development)

### Required Accounts & Keys
- Firebase Project (with Authentication enabled)
- Google Cloud Platform account (for Firebase Admin SDK)
- Database hosting (or use Docker PostgreSQL)
- Domain name (for production)
- SSL certificate (Let's Encrypt recommended)

## ⚙️ Environment Setup

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd AplicatieMesteri
```

### 2. Configure Environment Variables

#### Production Environment
```bash
# Copy the example file
cp .env.production.example .env.production

# Edit the file and fill in your actual values
nano .env.production  # or use your favorite editor
```

**Critical values to update:**
- `DB_PASSWORD` - Strong database password
- `FIREBASE_PROJECT_ID` - Your Firebase project ID
- `FIREBASE_SERVICE_ACCOUNT_KEY` - Full JSON service account key
- `FRONTEND_URL` - Your actual domain (e.g., https://mesteri.ro)
- `API_BASE_URL` - Your API domain (e.g., https://api.mesteri.ro)
- `JWT_SECRET` - Generate with: `openssl rand -base64 32`
- `SESSION_SECRET` - Generate with: `openssl rand -base64 32`

### 3. Firebase Setup

#### Get Firebase Service Account Key
1. Go to Firebase Console → Project Settings
2. Service Accounts → Generate New Private Key
3. Copy the entire JSON content
4. Minify it (remove line breaks) and add to `.env.production`

#### Configure Firebase Authentication
1. Enable Email/Password authentication
2. Enable Google Sign-In
3. Add your domain to authorized domains

## 💻 Local Development

### Start Development Environment
```bash
# Start backend and database
cd mesteri-platform/backend
npm install
npm run start:dev

# In another terminal, start Flutter app
cd mesteri-platform/app_client
flutter pub get
flutter run -d chrome  # For web
# or
flutter run  # For mobile emulator
```

### Access Local Services
- Frontend: http://localhost (or Flutter debug URL)
- Backend API: http://localhost:3000
- Database: localhost:5432

## 🚀 Production Deployment

### Option 1: Docker Compose (Recommended for VPS/Cloud VM)

#### Step 1: Prepare Server
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose-plugin
```

#### Step 2: Deploy Application
```bash
# Copy files to server
scp -r . user@your-server:/opt/mesteri-platform

# SSH into server
ssh user@your-server

# Navigate to project
cd /opt/mesteri-platform

# Run deployment script
chmod +x deploy.sh
./deploy.sh
```

**For Windows servers:**
```powershell
.\deploy.ps1
```

#### Step 3: Configure Nginx (Reverse Proxy)
```bash
# Install Nginx on host
sudo apt install nginx

# Copy configuration
sudo nano /etc/nginx/sites-available/mesteri

# Add this configuration:
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:3000;
        # ... same headers as above
    }

    location /socket.io {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/mesteri /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Step 4: Setup SSL (Let's Encrypt)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### Option 2: Kubernetes Deployment

See `infra/k8s/` directory for Kubernetes manifests.

```bash
# Apply Kubernetes configurations
kubectl apply -f infra/k8s/
```

### Option 3: Cloud Platform Deployment

#### Google Cloud Platform
```bash
# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT/mesteri-backend backend/
gcloud builds submit --tag gcr.io/YOUR_PROJECT/mesteri-frontend app_client/

# Deploy to Cloud Run
gcloud run deploy mesteri-backend \
  --image gcr.io/YOUR_PROJECT/mesteri-backend \
  --platform managed \
  --region us-central1

gcloud run deploy mesteri-frontend \
  --image gcr.io/YOUR_PROJECT/mesteri-frontend \
  --platform managed \
  --region us-central1
```

#### AWS (ECS)
See AWS documentation for ECS deployment with Docker images.

## ✅ Post-Deployment

### 1. Verify Services
```bash
# Check all containers are running
docker-compose -f docker-compose.prod.yml ps

# Check logs
docker-compose -f docker-compose.prod.yml logs -f

# Test backend health
curl https://api.yourdomain.com/api/health

# Test frontend
curl https://yourdomain.com/health
```

### 2. Database Migration
```bash
# Run migrations
docker-compose -f docker-compose.prod.yml exec backend npx prisma migrate deploy

# Seed initial data
docker-compose -f docker-compose.prod.yml exec backend npm run seed
```

### 3. Create Admin User
```bash
# Access backend container
docker-compose -f docker-compose.prod.yml exec backend sh

# Run admin creation script (create this if needed)
node scripts/create-admin.js
```

### 4. Configure Firebase
- Add production domain to Firebase authorized domains
- Update redirect URLs for OAuth
- Set up Firebase Hosting (optional)

## 📊 Monitoring & Maintenance

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f app-client
```

### Backup Database
```bash
# Create backup
docker-compose -f docker-compose.prod.yml exec postgres pg_dump -U mesteri_user mesteri_db > backup.sql

# Restore backup
docker-compose -f docker-compose.prod.yml exec -T postgres psql -U mesteri_user mesteri_db < backup.sql
```

### Update Application
```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml up -d --build
```

### Scaling
```bash
# Scale backend instances
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

## 🔒 Security Checklist

- [ ] Change all default passwords
- [ ] Enable SSL/TLS (HTTPS)
- [ ] Configure firewall (ufw or cloud firewall)
- [ ] Set up automated backups
- [ ] Enable Firebase App Check
- [ ] Configure CORS properly
- [ ] Set up monitoring/alerting
- [ ] Regular security updates
- [ ] Rate limiting on API endpoints
- [ ] DDoS protection (Cloudflare recommended)

## 🆘 Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs backend

# Check container status
docker ps -a
```

### Database Connection Issues
```bash
# Test database connection
docker-compose -f docker-compose.prod.yml exec postgres psql -U mesteri_user -d mesteri_db

# Check DATABASE_URL in backend
docker-compose -f docker-compose.prod.yml exec backend env | grep DATABASE_URL
```

### WebSocket Connection Failed
- Ensure nginx/reverse proxy is configured for WebSocket upgrades
- Check CORS settings in backend
- Verify firewall allows WebSocket connections

### High Memory Usage
```bash
# Check resource usage
docker stats

# Adjust Docker memory limits in docker-compose.prod.yml
```

## 📞 Support

For deployment issues:
1. Check logs first
2. Review this guide
3. Check GitHub Issues
4. Contact dev team

## 📝 License

Copyright © 2024 Mesteri Platform
