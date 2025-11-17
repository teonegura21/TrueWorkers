# 🚀 Mesteri Platform - Production Deployment Guide

**Last Updated**: January 2025
**Platform Status**: MVP Complete - Ready for Production
**Version**: 1.0.0

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Database Setup](#database-setup)
4. [Backend Deployment](#backend-deployment)
5. [Frontend Deployment](#frontend-deployment)
6. [Third-Party Services Setup](#third-party-services-setup)
7. [Testing Checklist](#testing-checklist)
8. [Post-Deployment](#post-deployment)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Services & Accounts

- [ ] **PostgreSQL Database** (v14+) with PostGIS extension
- [ ] **Firebase Account** for authentication and push notifications
- [ ] **Stripe Account** for payment processing
- [ ] **Google Cloud Storage** for file storage
- [ ] **SignRequest Account** for digital contract signing
- [ ] **SMTP Server** (Gmail recommended for starting)
- [ ] **Domain name** and SSL certificate

### Required Software

- Node.js v18+ and npm
- Flutter SDK 3.9+
- Docker & Docker Compose (optional but recommended)
- PostgreSQL client tools

---

## Environment Setup

### 1. Clone and Navigate to Project

```bash
git clone https://github.com/your-org/TrueWorkers.git
cd TrueWorkers/mesteri-platform
```

### 2. Backend Environment Configuration

```bash
cd backend
cp .env.example .env
```

Now edit `.env` with your actual credentials:

#### Required Environment Variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `FIREBASE_PROJECT_ID` | Firebase project ID | `mesteri-platform-prod` |
| `FIREBASE_SERVICE_ACCOUNT_KEY` | Firebase service account JSON | See `.env.example` |
| `STRIPE_SECRET_KEY` | Stripe secret key | `sk_live_...` or `sk_test_...` |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret | `whsec_...` |
| `GCS_CONTRACTS_BUCKET` | Google Cloud Storage bucket | `mesteri-contracts-prod` |
| `SMTP_USER` | Email account for notifications | `noreply@mesteri.ro` |
| `SMTP_PASS` | Email password/app password | (secure password) |
| `JWT_SECRET` | JWT signing secret | (generate: `openssl rand -base64 32`) |
| `SESSION_SECRET` | Session secret | (generate: `openssl rand -base64 32`) |

#### Generate Secure Secrets:

```bash
# Generate JWT secret
openssl rand -base64 32

# Generate session secret
openssl rand -base64 32
```

---

## Database Setup

### 1. Create Database and Enable PostGIS

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE mesteri_db;

# Connect to the database
\c mesteri_db

# Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

# Create user (if needed)
CREATE USER mesteri_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE mesteri_db TO mesteri_user;

# Exit
\q
```

### 2. Run Database Migrations

```bash
cd /path/to/mesteri-platform/backend

# Install dependencies
npm install

# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate deploy

# Seed database (optional - creates initial data)
npx prisma db seed
```

### 3. Verify Database

```bash
# Check tables were created
npx prisma studio
# Or
psql -U mesteri_user -d mesteri_db -c "\dt"
```

---

## Backend Deployment

### Option A: Docker Deployment (Recommended)

```bash
cd /path/to/mesteri-platform

# Build and start services
docker-compose -f docker-compose.prod.yml up -d

# Check logs
docker-compose logs -f backend

# Verify backend is running
curl http://localhost:3000/health
```

### Option B: Direct Node.js Deployment

```bash
cd backend

# Install production dependencies
npm ci --production

# Build TypeScript
npm run build

# Start with PM2 (recommended for production)
npm install -g pm2
pm2 start dist/main.js --name mesteri-api

# Or use Node.js directly
NODE_ENV=production node dist/main.js
```

### Configure Reverse Proxy (Nginx)

```nginx
server {
    listen 443 ssl http2;
    server_name api.mesteri.ro;

    ssl_certificate /path/to/ssl/fullchain.pem;
    ssl_certificate_key /path/to/ssl/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Frontend Deployment

### Client App (Homeowners)

```bash
cd app_client

# Update API endpoint
# Edit lib/src/core/config/api_config.dart
# Set baseUrl to: 'https://api.mesteri.ro'

# Build for web
flutter build web --release

# Deploy to hosting (e.g., Firebase Hosting)
firebase deploy --only hosting:client
```

### Craftsman App

```bash
cd app_mester

# Update API endpoint
# Edit lib/src/core/config/api_config.dart

# Build for web
flutter build web --release

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ipa --release

# Deploy
firebase deploy --only hosting:craftsman
```

---

## Third-Party Services Setup

### 1. Firebase Setup

#### Authentication:
1. Go to Firebase Console > Authentication
2. Enable Email/Password authentication
3. Enable Google Sign-In (optional)
4. Configure authorized domains

#### Cloud Messaging (Push Notifications):
1. Go to Firebase Console > Cloud Messaging
2. Download `google-services.json` (Android)
3. Download `GoogleService-Info.plist` (iOS)
4. Place files in respective app directories

#### Service Account:
1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate new private key"
3. Copy JSON content to `FIREBASE_SERVICE_ACCOUNT_KEY` in `.env`

### 2. Stripe Setup

#### Get API Keys:
1. Go to https://dashboard.stripe.com/apikeys
2. Copy "Secret key" → `STRIPE_SECRET_KEY`
3. Copy "Publishable key" → `STRIPE_PUBLISHABLE_KEY`

#### Configure Webhook:
1. Go to https://dashboard.stripe.com/webhooks
2. Click "Add endpoint"
3. Endpoint URL: `https://api.mesteri.ro/payments/stripe/webhook`
4. Events to send:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `charge.refunded`
5. Copy "Signing secret" → `STRIPE_WEBHOOK_SECRET`

#### Test Stripe Integration:
```bash
# Use Stripe CLI for local testing
stripe listen --forward-to http://localhost:3000/payments/stripe/webhook

# Test payment
curl -X POST http://localhost:3000/payments/stripe/create-payment-intent \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100,
    "projectId": "test-project",
    "clientId": "test-client",
    "craftsmanId": "test-craftsman"
  }'
```

### 3. Google Cloud Storage Setup

#### Create Bucket:
```bash
# Using gcloud CLI
gcloud storage buckets create gs://mesteri-contracts-prod \
  --location=europe-west3 \
  --uniform-bucket-level-access

# Or via Google Cloud Console
# Storage > Create Bucket > Configure settings
```

#### Create Service Account:
1. IAM & Admin > Service Accounts > Create Service Account
2. Grant "Storage Object Admin" role
3. Create key (JSON)
4. Save key file securely
5. Set `GCS_KEY_FILE` in `.env`

### 4. SignRequest Setup

1. Create account at https://signrequest.com/
2. Go to API settings
3. Copy API token → `SIGNREQUEST_API_TOKEN`
4. For production, verify webhook URL

### 5. SMTP Setup (Gmail)

1. Enable 2-Factor Authentication on Google Account
2. Generate App Password:
   - Google Account > Security > 2-Step Verification > App passwords
3. Create new app password for "Mail"
4. Copy generated password → `SMTP_PASS`

---

## Testing Checklist

### Backend Health Checks

```bash
# Health check
curl https://api.mesteri.ro/health

# Database connection
curl https://api.mesteri.ro/api/health/db

# Authentication
curl -X POST https://api.mesteri.ro/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

### Feature Testing Checklist

- [ ] User registration and login
- [ ] Job posting
- [ ] Craftsman profile viewing
- [ ] Real-time messaging
- [ ] Payment flow (test mode)
- [ ] Contract generation
- [ ] Email notifications
- [ ] Push notifications
- [ ] File uploads (images/videos)
- [ ] Reviews and ratings

---

## Post-Deployment

### 1. Database Migrations

After deploying schema changes:

```bash
npx prisma migrate deploy
```

### 2. Monitoring Setup

#### Backend Logs:
```bash
# Using PM2
pm2 logs mesteri-api

# Using Docker
docker-compose logs -f backend

# Save logs
pm2 install pm2-logrotate
```

#### Error Tracking:
Consider integrating:
- Sentry for error tracking
- LogRocket for session replay
- DataDog for APM

### 3. Backup Strategy

#### Database Backups:
```bash
# Create backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -U mesteri_user mesteri_db > backup_$DATE.sql

# Automate with cron
0 2 * * * /path/to/backup-script.sh
```

#### File Storage Backups:
```bash
# Backup GCS bucket
gsutil -m rsync -r gs://mesteri-contracts-prod /backup/gcs
```

### 4. SSL Certificate Setup

```bash
# Using Let's Encrypt with Certbot
certbot --nginx -d api.mesteri.ro -d app.mesteri.ro

# Auto-renewal (add to crontab)
0 0 1 * * certbot renew --quiet
```

---

## Troubleshooting

### Common Issues

#### 1. Database Connection Fails
```bash
# Check PostgreSQL is running
systemctl status postgresql

# Check connection
psql -U mesteri_user -d mesteri_db -c "SELECT 1"

# Check DATABASE_URL format
# postgresql://USER:PASSWORD@HOST:PORT/DATABASE
```

#### 2. Stripe Webhooks Not Receiving Events
- Verify webhook URL is publicly accessible
- Check `STRIPE_WEBHOOK_SECRET` matches Stripe dashboard
- Test with Stripe CLI: `stripe listen --forward-to https://api.mesteri.ro/payments/stripe/webhook`

#### 3. Firebase Authentication Fails
- Verify `FIREBASE_SERVICE_ACCOUNT_KEY` is valid JSON
- Check Firebase project ID matches
- Ensure authorized domains are configured in Firebase Console

#### 4. File Uploads Fail
- Check GCS bucket permissions
- Verify service account has "Storage Object Admin" role
- Check `GCS_CONTRACTS_BUCKET` environment variable

#### 5. Emails Not Sending
- Verify SMTP credentials
- Check Gmail app password is correct
- Ensure 2FA is enabled on Google account
- Check SMTP port (587 for TLS)

### Debug Mode

Enable debug logging:

```bash
# In .env
LOG_LEVEL=debug
NODE_ENV=development  # Temporarily
```

### Health Checks

```bash
# Backend health
curl https://api.mesteri.ro/health

# Database connectivity
curl https://api.mesteri.ro/api/health/db

# Storage connectivity
curl https://api.mesteri.ro/api/health/storage
```

---

## Security Checklist

- [ ] All environment variables secured
- [ ] `.env` file not in version control
- [ ] SSL certificates installed and auto-renewing
- [ ] Firewall configured (only ports 80, 443, 22 open)
- [ ] Database password is strong
- [ ] JWT secrets are random and secure
- [ ] CORS configured for production domains only
- [ ] Rate limiting enabled
- [ ] Input validation enabled
- [ ] SQL injection protection verified
- [ ] XSS protection verified
- [ ] CSRF protection enabled

---

## Performance Optimization

### Database Indexing

```sql
-- Already created in migrations, but verify:
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_jobs_location ON jobs USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_payments_stripe_intent ON payments(stripe_payment_intent_id);
```

### Caching Strategy

```typescript
// Implement Redis caching for frequently accessed data
// In future updates, consider:
// - User profile caching
// - Craftsman search results caching
// - Job listings caching
```

### CDN Setup

- Configure CloudFlare or similar CDN for static assets
- Enable gzip compression
- Implement browser caching headers

---

## Maintenance

### Regular Tasks

**Daily:**
- Check error logs
- Monitor payment transactions
- Verify webhook deliveries

**Weekly:**
- Review database backups
- Check disk space
- Review user feedback

**Monthly:**
- Update dependencies
- Review security patches
- Analyze performance metrics

---

## Support & Documentation

### Documentation Links

- Backend API Docs: `/api-docs` (Swagger)
- CLAUDE.md: Complete technical documentation
- Database Schema: `prisma/schema.prisma`
- API Client Examples: In Flutter apps

### Getting Help

For issues or questions:
1. Check logs first: `pm2 logs` or `docker logs`
2. Review this guide's troubleshooting section
3. Check environment variables configuration
4. Verify third-party service status (Stripe, Firebase, GCS)

---

## 🎉 Congratulations!

Your Mesteri Platform is now live!

**Next Steps:**
1. Monitor initial user sign-ups
2. Test payment flow with real transactions (small amounts first)
3. Verify email notifications are working
4. Check contract generation and signing workflow
5. Monitor error logs for any issues

**Production URLs:**
- API: https://api.mesteri.ro
- Client App: https://app.mesteri.ro
- Craftsman App: https://mester.mesteri.ro

---

**Made with ❤️ in Romania** 🇷🇴
**Version 1.0.0 - MVP Release**
