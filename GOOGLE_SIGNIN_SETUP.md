# Google Sign-In Setup Guide - Android & iOS

**Date**: January 2025
**App**: True Workers (Mesteri Platform)
**Status**: Step-by-step configuration guide

---

## ✅ Your Android SHA-1 Fingerprint (Debug)

```
12:A5:77:FD:D5:02:1E:48:61:F7:91:4C:CB:C4:70:CA:F7:23:95:2F
```

---

## 🔥 STEP 1: Configure Firebase Console

### A. Add SHA-1 to Android App

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**
3. Click **⚙️ Project Settings** (gear icon in top left)
4. Scroll to **"Your apps"** section
5. Find **Android app** with package name: `ro.trueworkers.client`
6. Click to expand the app
7. Scroll down to **"SHA certificate fingerprints"**
8. Click **"Add fingerprint"**
9. Paste this SHA-1:
   ```
   12:A5:77:FD:D5:02:1E:48:61:F7:91:4C:CB:C4:70:CA:F7:23:95:2F
   ```
10. Click **Save**

### B. Enable Google Sign-In

1. In Firebase Console sidebar, go to **Authentication**
2. Click **"Sign-in method"** tab
3. Find **Google** in the provider list
4. Click **Google** to expand
5. Toggle **"Enable"** to ON
6. **Select support email** (your email)
7. Click **Save**

---

## 📱 STEP 2: iOS Configuration

### A. Register iOS App in Firebase

1. In **Firebase Console** → **Project Settings**
2. Click **"Add app"** button
3. Select **iOS** (Apple icon)
4. Enter **iOS bundle ID**: `com.mesteri.appClient`
5. **App nickname**: `Mesteri Client iOS` (optional)
6. **App Store ID**: Leave blank for now
7. Click **"Register app"**

### B. Download GoogleService-Info.plist

1. After registering, Firebase will show **"Download GoogleService-Info.plist"**
2. Click **"Download GoogleService-Info.plist"**
3. Save the file to your computer

### C. Add GoogleService-Info.plist to iOS Project

**IMPORTANT**: You need to add this file using Xcode (not just copy-paste)

1. Open Xcode
2. Navigate to your project folder:
   ```
   C:\Users\TEODO\Desktop\Facultate\Proiecte\AplicatieMesteri\mesteri-platform\app_client\ios
   ```
3. Double-click `Runner.xcworkspace` to open in Xcode
4. In Xcode, in the left sidebar (Project Navigator), find the **Runner** folder
5. Right-click on **Runner** folder
6. Select **"Add Files to Runner..."**
7. Navigate to your downloaded `GoogleService-Info.plist` file
8. **IMPORTANT**: Check **"Copy items if needed"**
9. **IMPORTANT**: Make sure **"Runner" target is checked**
10. Click **"Add"**

### D. Get REVERSED_CLIENT_ID from GoogleService-Info.plist

1. Open the `GoogleService-Info.plist` file you downloaded (with a text editor)
2. Find the line with `<key>REVERSED_CLIENT_ID</key>`
3. The next line will have the value like:
   ```xml
   <string>com.googleusercontent.apps.123456789-xxxxxxxx</string>
   ```
4. **Copy this entire string** (e.g., `com.googleusercontent.apps.123456789-xxxxxxxx`)
5. **Keep it handy** - you'll need it in the next step

### E. Update Info.plist for Google Sign-In

Now you need to add URL scheme to iOS Info.plist:

1. Open the file:
   ```
   C:\Users\TEODO\Desktop\Facultate\Proiecte\AplicatieMesteri\mesteri-platform\app_client\ios\Runner\Info.plist
   ```

2. Add this code **before the closing `</dict>` tag** (around line 54):

   ```xml
   <!-- Google Sign-In URL Scheme -->
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <!-- Replace with your actual REVERSED_CLIENT_ID from GoogleService-Info.plist -->
               <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
           </array>
       </dict>
   </array>
   ```

3. **Replace** `com.googleusercontent.apps.YOUR-CLIENT-ID` with your actual **REVERSED_CLIENT_ID** from step D

---

## 📱 STEP 3: Verify Android Configuration

### Check google-services.json

Your Android `google-services.json` is already in place at:
```
mesteri-platform/app_client/android/app/google-services.json
```

✅ **This is already configured!**

### Download Updated google-services.json (Optional but Recommended)

After adding the SHA-1 fingerprint, it's good practice to download a fresh `google-services.json`:

1. In **Firebase Console** → **Project Settings**
2. Find your **Android app** (`ro.trueworkers.client`)
3. Click **"Download google-services.json"**
4. Replace the existing file at:
   ```
   mesteri-platform/app_client/android/app/google-services.json
   ```

---

## 🧪 STEP 4: Test Google Sign-In

### On Android Emulator:

1. Make sure the emulator has **Google Play Services** installed
2. Sign in to a Google account on the emulator (Settings → Accounts)
3. Run your app
4. Tap **"Continue with Google"**
5. Select a Google account
6. If it works, you'll see the account picker and can sign in!

### On iOS Simulator:

1. iOS Simulator doesn't support Google Sign-In (requires real device)
2. For testing on simulator, use **Email/Password** authentication instead
3. For full testing, you need a **real iPhone/iPad device**

---

## 🔧 Common Issues & Solutions

### Android: "API not enabled" or "Developer Error"

**Solution**: Make sure you added the SHA-1 fingerprint in Firebase Console

### Android: "Sign-in failed" or "12501 error"

**Solution**:
- Ensure SHA-1 is added to Firebase
- Make sure Google Sign-In is **enabled** in Firebase Authentication
- Download fresh `google-services.json` after adding SHA-1

### iOS: "Error 1000" or "Invalid Client ID"

**Solution**:
- Verify `GoogleService-Info.plist` is added to Xcode project correctly
- Check that `REVERSED_CLIENT_ID` is added to `Info.plist` URL schemes
- Make sure bundle ID matches: `com.mesteri.appClient`

### iOS: Simulator shows "Unable to sign in"

**Solution**: Google Sign-In doesn't work on iOS Simulator. Use a real device.

---

## ✅ Checklist

### Android:
- [x] SHA-1 fingerprint added to Firebase Console
- [x] Google Sign-In enabled in Firebase Authentication
- [x] `google-services.json` in place
- [x] Code updated to use `google_sign_in` package
- [ ] Tested on Android emulator with Google account

### iOS:
- [ ] iOS app registered in Firebase Console
- [ ] `GoogleService-Info.plist` downloaded
- [ ] `GoogleService-Info.plist` added to Xcode project (with "Copy items if needed")
- [ ] `REVERSED_CLIENT_ID` copied from plist
- [ ] `CFBundleURLTypes` added to `Info.plist` with REVERSED_CLIENT_ID
- [ ] Tested on real iPhone/iPad device (not simulator)

---

## 📚 Additional Resources

- **Firebase Console**: https://console.firebase.google.com/
- **Google Sign-In Flutter Docs**: https://pub.dev/packages/google_sign_in
- **Firebase Auth Flutter Docs**: https://firebase.google.com/docs/auth/flutter/start

---

**Last Updated**: January 2025
**Your Debug SHA-1**: `12:A5:77:FD:D5:02:1E:48:61:F7:91:4C:CB:C4:70:CA:F7:23:95:2F`
