# ZindeAI MVP v1.8

ZindeAI is an intelligent nutrition planning system specifically designed for Turkish cuisine. This MVP version focuses on core functionality: photo-based food logging with AI-powered macro estimation.

## 🎯 Features (MVP v1.8)

### Core Features
- **FoodSnap**: Take photos of your meals and get instant macro estimates
- **Smart AI Analysis**: Uses Groq AI to analyze Turkish cuisine and estimate calories, protein, carbs, and fat
- **Daily Timeline**: Track all your meals throughout the day
- **Simple Profile**: Set height, weight, and target calories with BMI calculation

### Technology Stack
- **Flutter**: Cross-platform mobile development
- **Firebase**: Backend services (Firestore, Storage, Remote Config)
- **Groq API**: AI-powered food analysis using `gemma2-9b-it` model
- **Google Cloud**: Storage and database hosting

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.0.0)
- Firebase project with Firestore, Storage, and Remote Config enabled
- Groq API account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/lastlord44/ZindeAI.git
cd ZindeAI
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Enable Firestore, Firebase Storage, and Remote Config
   - Download and add configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)

4. Set up Groq API:
   - Get your API key from [Groq Console](https://console.groq.com/)
   - Add the API key to Firebase Remote Config with key `groq_api_key`

5. Run the app:
```bash
flutter run
```

## 📱 How to Use

1. **First Time Setup**:
   - Open the app and go to Profile
   - Enter your height, weight, and target daily calories
   - Save your profile

2. **Log Your Meals**:
   - Tap the camera button (+) on the home screen
   - Take a photo of your food or select from gallery
   - Enter a description (e.g., "Menemen with bread, Turkish tea")
   - Tap "Estimate Macros" to get AI analysis
   - Review the results and tap "Save Meal"

3. **Track Progress**:
   - View your daily summary on the home screen
   - See all logged meals in chronological order
   - Monitor your macro intake throughout the day

## 🏗️ Project Structure

```
lib/
├── models/
│   ├── meal.dart          # Meal data model
│   └── user.dart          # User profile model
├── services/
│   ├── camera_service.dart    # Camera and gallery operations
│   ├── groq_service.dart      # AI macro estimation
│   └── storage_service.dart   # Firebase Firestore & Storage
├── screens/
│   ├── home_screen.dart       # Main timeline view
│   ├── camera_screen.dart     # Photo capture and analysis
│   └── profile_screen.dart    # User profile management
└── main.dart              # App entry point
```

## 🔧 Configuration

### Firebase Setup
1. Create collections in Firestore:
   - `users`: User profiles
   - `meals`: Meal entries

2. Set up Firebase Storage buckets:
   - `photos/{userId}/`: Original meal photos

3. Configure Remote Config:
   - `groq_api_key`: Your Groq API key

### Groq API Configuration
- Model: `gemma2-9b-it`
- Free tier: 14,400 requests/day
- Response format: JSON object
- Specialized for Turkish cuisine

## 💰 Cost Structure

### Development Phase (0-3 months)
- **Groq API**: Free tier (14,400 req/day)
- **Google Cloud**: $300 credit
- **Total**: $0/month

### Early Growth (3-6 months)
- **Groq API**: ~$20/month (after free tier)
- **Firebase**: ~$25/month (Blaze plan)
- **Total**: ~$45/month

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📋 Roadmap

### Phase 1 (Current - MVP v1.8)
- [x] Basic photo capture and macro estimation
- [x] Daily meal timeline
- [x] Simple user profile
- [x] Firebase integration

### Phase 2 (v1.9 - Enhanced Features)
- [ ] Barcode scanning integration
- [ ] Meal templates for common Turkish dishes
- [ ] Water intake tracking
- [ ] Weekly summary reports

### Phase 3 (v2.0 - Advanced Features)
- [ ] AI vision models for automatic food recognition
- [ ] Personalized recommendations
- [ ] Social features and meal sharing
- [ ] Advanced analytics and insights

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎯 About ZindeAI

ZindeAI is focused on making nutrition tracking simple and accurate for Turkish cuisine. By combining AI technology with local food knowledge, we aim to help users make better dietary choices effortlessly.

**Version**: v1.8 (MVP)  
**Target Audience**: Turkish food enthusiasts and health-conscious individuals  
**Platform**: iOS and Android via Flutter

---

*Built with ❤️ for the Turkish community*
