# Firebase Configuration Files

This directory contains Firebase configuration files for the TrueWorkers platform.

## 📁 Directory Structure

```
firebase-config/
├── dev/
│   ├── android/
│   │   ├── client-google-services.json      # Client Android - Development
│   │   └── craftsman-google-services.json   # Craftsman Android - Development
│   ├── ios/
│   │   ├── client-GoogleService-Info.plist  # Client iOS - Development
│   │   └── craftsman-GoogleService-Info.plist # Craftsman iOS - Development
│   └── service-account-key.json             # Admin SDK - Development
├── staging/
│   ├── android/
│   │   ├── client-google-services.json      # Client Android - Staging
│   │   └── craftsman-google-services.json   # Craftsman Android - Staging
│   ├── ios/
│   │   ├── client-GoogleService-Info.plist  # Client iOS - Staging
│   │   └── craftsman-GoogleService-Info.plist # Craftsman iOS - Staging
│   └── service-account-key.json             # Admin SDK - Staging
└── prod/
    ├── android/
    │   ├── client-google-services.json      # Client Android - Production
    │   └── craftsman-google-services.json   # Craftsman Android - Production
    ├── ios/
    │   ├── client-GoogleService-Info.plist  # Client iOS - Production
    │   └── craftsman-GoogleService-Info.plist # Craftsman iOS - Production
    └── service-account-key.json             # Admin SDK - Production
```

## 🔑 Configuration Files Needed

### 1. Google Services Files (Flutter Apps)
After creating the Android apps in Firebase Console:
1. Download `google-services.json` for each app
2. Rename and place them according to the structure above
3. Copy to Flutter app directories when ready

### 2. Service Account Keys (Backend)
For Firebase Admin SDK authentication:
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save as `service-account-key.json` in appropriate environment folder

## ⚠️ Security Notes

- **NEVER commit these files to version control**
- Use environment variables in production
- Store securely in your deployment system
- Rotate service account keys regularly

## 🔄 Environment Variable Mapping

```bash
# Development
FIREBASE_PROJECT_ID=trueworkers-dev
FIREBASE_SERVICE_ACCOUNT_KEY="$(cat firebase-config/dev/service-account-key.json)"

# Staging  
FIREBASE_PROJECT_ID=trueworkers-staging
FIREBASE_SERVICE_ACCOUNT_KEY="$(cat firebase-config/staging/service-account-key.json)"

# Production
FIREBASE_PROJECT_ID=trueworkers-prod
FIREBASE_SERVICE_ACCOUNT_KEY="$(cat firebase-config/prod/service-account-key.json)"
```