# ZindeAI MVP v1.8 - Setup Instructions

## Quick Start Guide

### 1. Prerequisites
- Flutter SDK (>=3.3.0) - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
- Dart SDK (>=3.0.0) - Included with Flutter
- Android Studio or VS Code with Flutter extensions
- Firebase account
- Groq API account

### 2. Install Dependencies
```bash
cd ZindeAI
flutter pub get
```

### 3. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "zindeai-mvp"
3. Enable the following services:
   - **Firestore Database**: Create in production mode
   - **Firebase Storage**: Default settings
   - **Remote Config**: Default settings

4. Add Android app:
   - Package name: `com.zindeai.app`
   - Download `google-services.json`
   - Place in `android/app/google-services.json`

5. Add iOS app:
   - Bundle ID: `com.zindeai.app`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/GoogleService-Info.plist`

### 4. Groq API Setup
1. Sign up at [Groq Console](https://console.groq.com/)
2. Create an API key
3. In Firebase Console, go to Remote Config
4. Add parameter:
   - Key: `groq_api_key`
   - Value: Your Groq API key
   - Condition: Default (no conditions)
5. Publish changes

### 5. Firebase Rules Setup

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own meals
    match /meals/{mealId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload photos to their own folder
    match /photos/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 6. Run the App
```bash
# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

### 7. Build for Release

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (requires macOS)
```bash
flutter build ios --release
# Then use Xcode to build for distribution
```

## Development Workflow

### 1. Code Structure
- `lib/models/`: Data models (User, Meal)
- `lib/services/`: Business logic services
- `lib/screens/`: UI screens
- `test/`: Unit tests

### 2. Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models_test.dart

# Run tests with coverage
flutter test --coverage
```

### 3. Code Analysis
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format lib/ test/
```

## Troubleshooting

### Common Issues

1. **Firebase not initializing**
   - Ensure `google-services.json` and `GoogleService-Info.plist` are in correct locations
   - Check package names match Firebase configuration

2. **Groq API errors**
   - Verify API key is set in Firebase Remote Config
   - Check Remote Config is published
   - Ensure internet connectivity

3. **Camera permissions**
   - Android: Check `AndroidManifest.xml` has camera permissions
   - iOS: Check `Info.plist` has camera usage descriptions

4. **Build errors**
   - Run `flutter clean` then `flutter pub get`
   - Update Flutter: `flutter upgrade`
   - Check minimum SDK requirements

### Environment Variables
Create `.env` file for local development:
```
GROQ_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=zindeai-mvp
```

### Debug Mode Features
- Hot reload: `r` in terminal
- Hot restart: `R` in terminal
- Open DevTools: `d` in terminal
- Quit: `q` in terminal

## Deployment

### Android Play Store
1. Build app bundle: `flutter build appbundle --release`
2. Sign with release key
3. Upload to Play Console
4. Configure store listing

### iOS App Store
1. Build for iOS: `flutter build ios --release`
2. Open in Xcode
3. Archive and upload to App Store Connect
4. Configure app metadata

## Monitoring

### Firebase Analytics
- Enable in Firebase Console
- View user engagement and app performance

### Crash Reporting
- Enable Firebase Crashlytics
- Monitor app stability

### Remote Config
- Monitor API usage
- Adjust feature flags
- Update configurations without app updates

## Next Steps

After MVP validation:
1. Add authentication (Firebase Auth)
2. Implement proper error handling
3. Add offline support
4. Integrate vision models
5. Add premium features

---

**Need Help?**
- Check [Flutter Documentation](https://flutter.dev/docs)
- Review [Firebase Documentation](https://firebase.google.com/docs)
- See project issues on GitHub