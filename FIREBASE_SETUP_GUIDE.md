# Firebase Configuration Setup Guide

**Date**: January 2025
**Project**: Mesteri Platform
**Status**: Manual Configuration Required

---

## 📋 Current Configuration

### App Client (Homeowners App)
- **Package Name (Android)**: `ro.trueworkers.client`
- **Bundle ID (iOS)**: `com.mesteri.appClient`
- **App Directory**: `mesteri-platform/app_client/`

### App Mester (Craftsman App)
- **Package Name (Android)**: `ro.trueworkers.mester`
- **Bundle ID (iOS)**: `com.mesteri.appMester`
- **App Directory**: `mesteri-platform/app_mester/`

### Firebase Project
- **Project ID**: `trueworkers-dev` (or create new one)
- **Project Name**: Your choice (e.g., "Mesteri Platform")

---

## 🔥 Step-by-Step Firebase Setup

### Step 1: Access Firebase Console

1. Go to https://console.firebase.google.com/
2. Sign in with your Google account
3. Either:
   - **Create a new project** named "Mesteri Platform" or similar
   - **Select existing project** if you already have one

---

### Step 2: Register Android App (Client App)

#### 2.1 Add Android App to Firebase
1. In Firebase Console, click **"Add app"** or the **Android icon**
2. Fill in the following:
   - **Android package name**: `ro.trueworkers.client`
   - **App nickname** (optional): `Mesteri Client`
   - **Debug signing certificate SHA-1** (optional for now): Leave blank
3. Click **"Register app"**

#### 2.2 Download google-services.json
1. Firebase will generate a `google-services.json` file
2. Click **"Download google-services.json"**
3. Save it to your computer
4. **Copy this file** to:
   ```
   mesteri-platform/app_client/android/app/google-services.json
   ```
   ⚠️ **Important**: Replace the existing file

#### 2.3 Verify Configuration (Already Done ✓)
Your `build.gradle.kts` already has Google Services plugin configured:
```kotlin
id("com.google.gms.google-services")  // ✓ Already configured
```

---

### Step 3: Register Android App (Craftsman App)

#### 3.1 Add Second Android App
1. In Firebase Console, click **"Add app"** again
2. Select **Android icon**
3. Fill in:
   - **Android package name**: `ro.trueworkers.mester`
   - **App nickname** (optional): `Mesteri Craftsman`
   - **Debug signing certificate SHA-1**: Leave blank
4. Click **"Register app"**

#### 3.2 Download google-services.json for Craftsman App
1. Download the **second** `google-services.json`
2. **Copy this file** to:
   ```
   mesteri-platform/app_mester/android/app/google-services.json
   ```

---

### Step 4: Get Firebase Configuration Values

After registering both apps, you need to get the configuration values for `firebase_options.dart`.

#### 4.1 For Client App (ro.trueworkers.client)

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **"Your apps"** section
3. Find **ro.trueworkers.client** (Mesteri Client)
4. Click on the app
5. Scroll down to **"SDK setup and configuration"**
6. Select **"Config"** (not code)
7. Copy these values:

```dart
// For Android
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY_HERE',              // Copy from Firebase Console
  appId: '1:YOUR_PROJECT_NUMBER:android:YOUR_APP_ID', // Copy from Firebase Console
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',     // Copy from Firebase Console
  projectId: 'YOUR_PROJECT_ID',                      // Usually 'trueworkers-dev' or similar
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',      // Copy from Firebase Console
);
```

#### 4.2 For iOS (if you plan to deploy to iOS)

1. In Firebase Console Project Settings
2. Click **"Add app"** → Select **iOS icon**
3. Enter **iOS bundle ID**: `com.mesteri.appClient`
4. Download `GoogleService-Info.plist`
5. Copy to: `mesteri-platform/app_client/ios/Runner/GoogleService-Info.plist`
6. Get iOS configuration values similar to Android

#### 4.3 For Web (if you plan to deploy to web)

1. In Firebase Console Project Settings
2. Click **"Add app"** → Select **Web icon** (</>)
3. Register the web app
4. Copy the configuration values

---

### Step 5: Update firebase_options.dart Files

#### 5.1 Update Client App Configuration

**File**: `mesteri-platform/app_client/lib/firebase_options.dart`

Replace the dummy values with real values from Firebase Console:

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',                    // From Firebase Console
    appId: '1:PROJECT_NUMBER:web:WEB_APP_ID',       // From Firebase Console
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',  // From Firebase Console
    projectId: 'YOUR_PROJECT_ID',                   // e.g., 'trueworkers-dev'
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',                         // ← REPLACE THIS
    appId: '1:PROJECT_NUMBER:android:ANDROID_APP_ID',        // ← REPLACE THIS
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',           // ← REPLACE THIS
    projectId: 'YOUR_PROJECT_ID',                            // ← REPLACE THIS
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',            // ← REPLACE THIS
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',                     // From Firebase Console
    appId: '1:PROJECT_NUMBER:ios:IOS_APP_ID',        // From Firebase Console
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',   // From Firebase Console
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.mesteri.appClient',
  );

  // You can leave macOS and windows as is, or remove them if not needed
}
```

#### 5.2 Update Craftsman App Configuration

**File**: `mesteri-platform/app_mester/lib/firebase_options.dart`

Do the same for the craftsman app, using the values for `ro.trueworkers.mester`.

---

### Step 6: Enable Firebase Services

In Firebase Console, enable the services you need:

#### 6.1 Authentication
1. Go to **Authentication** → **Get Started**
2. Click **Sign-in method** tab
3. Enable:
   - ✅ **Email/Password**
   - ✅ **Google** (optional)
4. Save

#### 6.2 Cloud Firestore (Optional)
1. Go to **Firestore Database** → **Create database**
2. Select **Start in test mode** (for development)
3. Choose a location (e.g., `europe-west3` for Europe)
4. Click **Enable**

#### 6.3 Cloud Messaging (For Push Notifications)
1. Go to **Cloud Messaging**
2. If prompted, click **Enable**
3. This is automatically enabled when you add apps

#### 6.4 Storage (For Media Files)
1. Go to **Storage** → **Get Started**
2. Start in **test mode** (for development)
3. Click **Next** and **Done**

---

### Step 7: Verify Configuration

After updating the files:

#### 7.1 Clean and Rebuild
```bash
# For Client App
cd mesteri-platform/app_client
flutter clean
flutter pub get
flutter run
```

#### 7.2 Check for Errors
- The "Firebase Installations Service is unavailable" error should be gone
- The "Duplicate Firebase App" error is already fixed
- You should see successful Firebase initialization in logs

---

## 🔍 Where to Find Configuration Values

### Firebase Console Navigation:

1. **Project Settings**:
   - Click the **gear icon** ⚙️ next to "Project Overview"
   - Scroll to **"Your apps"** section

2. **For Each App** (Client & Craftsman):
   - Click on the app name (e.g., "ro.trueworkers.client")
   - Scroll to **"SDK setup and configuration"**
   - Select **"Config"** radio button
   - You'll see all the values you need:
     ```javascript
     const firebaseConfig = {
       apiKey: "...",              // Copy this
       authDomain: "...",           // Copy this
       projectId: "...",            // Copy this
       storageBucket: "...",        // Copy this
       messagingSenderId: "...",    // Copy this
       appId: "...",                // Copy this
     };
     ```

---

## 📝 Configuration Checklist

### For Client App (app_client):
- [ ] Register Android app in Firebase (`ro.trueworkers.client`)
- [ ] Download and place `google-services.json` in `app_client/android/app/`
- [ ] Update `app_client/lib/firebase_options.dart` with real values
- [ ] Register iOS app in Firebase (if deploying to iOS)
- [ ] Download and place `GoogleService-Info.plist` in `app_client/ios/Runner/`
- [ ] Enable Authentication in Firebase Console
- [ ] Enable Cloud Messaging in Firebase Console

### For Craftsman App (app_mester):
- [ ] Register Android app in Firebase (`ro.trueworkers.mester`)
- [ ] Download and place `google-services.json` in `app_mester/android/app/`
- [ ] Update `app_mester/lib/firebase_options.dart` with real values
- [ ] Register iOS app in Firebase (if deploying to iOS)
- [ ] Download and place `GoogleService-Info.plist` in `app_mester/ios/Runner/`

---

## 🚨 Important Security Notes

1. **Never commit real Firebase API keys to public repositories**
   - Add `firebase_options.dart` to `.gitignore` if repository is public
   - Use environment-specific configurations

2. **Use Firebase Security Rules**
   - Set up proper Firestore security rules
   - Configure Storage security rules
   - Review Authentication settings

3. **For Production**:
   - Create a separate Firebase project for production
   - Use release SHA-1 fingerprints for Android
   - Enable App Check for additional security

---

## 🎯 Quick Test After Configuration

After updating the configuration files, test if Firebase is working:

```dart
// This should work without errors
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

Run the app and check the logs:
- ✅ Should see: "Firebase initialized successfully"
- ❌ Should NOT see: "Firebase Installations Service is unavailable"
- ❌ Should NOT see: "Duplicate Firebase App"

---

## 📞 Need Help?

If you encounter issues:

1. **Check Firebase Console**: Ensure apps are properly registered
2. **Verify Package Names**: Must match exactly (`ro.trueworkers.client`)
3. **Check google-services.json**: Must be in correct location
4. **Clean Project**: Run `flutter clean` and `flutter pub get`
5. **Review Logs**: Look for specific Firebase error messages

---

**Last Updated**: January 2025
**Created for**: Mesteri Platform - Client & Craftsman Apps
