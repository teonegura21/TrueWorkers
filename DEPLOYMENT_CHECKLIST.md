# Contract System Deployment Checklist

## ✅ Pre-Deployment Verification

### Backend Setup
- [ ] Run Prisma migration: `cd backend && npx prisma migrate dev --name add_contract_signatures`
- [ ] Generate Prisma client: `npx prisma generate`
- [ ] Verify Puppeteer installation: `npm list puppeteer`
- [ ] Test Puppeteer Chrome: `node -e "require('puppeteer').launch().then(b => b.close())"`
- [ ] Verify GCS bucket exists and is accessible
- [ ] Set environment variables in `.env`:
  ```
  CONTRACT_BUCKET_NAME=mesteri-contracts-dev
  APPLICATION_ENV=dev
  GCS_SIGNED_URLS=enabled
  ```

### Flutter Setup
- [ ] Run `flutter pub get` in `app_client/`
- [ ] Run `flutter pub get` in `app_mester/`
- [ ] Configure API base URL in both apps
- [ ] Update Firebase configuration files
- [ ] Test signature package on target devices

### Testing
- [ ] Run backend: `npm run start:dev`
- [ ] Test contract creation endpoint
- [ ] Test PDF generation (verify Romanian template)
- [ ] Test signature submission
- [ ] Test contract retrieval with signed URLs
- [ ] Verify notifications sent correctly
- [ ] Test Flutter screens on iOS and Android
- [ ] Test end-to-end workflow

## 🚀 Deployment Steps

### Backend Deployment
1. [ ] Build production bundle: `npm run build`
2. [ ] Deploy to server (Docker, Heroku, etc.)
3. [ ] Run migrations on production database
4. [ ] Verify environment variables set
5. [ ] Test all endpoints in production
6. [ ] Monitor logs for errors

### Flutter Deployment
1. [ ] Build release APK: `flutter build apk --release`
2. [ ] Build iOS app: `flutter build ios --release`
3. [ ] Test on physical devices
4. [ ] Upload to Play Store (internal testing)
5. [ ] Upload to TestFlight (internal testing)
6. [ ] Distribute to beta testers

## 📊 Post-Deployment Monitoring

### Metrics to Track
- [ ] PDF generation success rate (target: >98%)
- [ ] Average PDF generation time (target: <10s)
- [ ] Signature submission success rate (target: >99%)
- [ ] Contract status distribution
- [ ] Time from creation to full execution
- [ ] Error rates per endpoint

### Alerts to Configure
- [ ] PDF generation failures >5%
- [ ] GCS upload failures
- [ ] Puppeteer crashes
- [ ] Database connection issues
- [ ] API response time >3s

## ✅ System Ready
All implementation tasks completed. System is production-ready pending deployment and final testing.
