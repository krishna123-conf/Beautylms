# Flutter Frontend Quick Start Guide

Get the Beauty LMS Flutter app running in 5 minutes!

## Prerequisites Check

```bash
# Check if Flutter is installed
flutter --version

# If not installed, follow: https://docs.flutter.dev/get-started/install
```

## Quick Setup

### 1. Navigate to Flutter Project

```bash
cd flutter_frontend
```

### 2. Get Dependencies

```bash
flutter pub get
```

### 3. Start Backend (in another terminal)

```bash
cd ../backend
npm install  # if not already done
npm start
```

The backend should be running on `http://localhost:3000`

### 4. Run Flutter App

Choose your platform:

**Web (Recommended for testing)**
```bash
flutter run -d chrome
```

**Android**
```bash
flutter run -d android
```

**iOS (macOS only)**
```bash
flutter run -d ios
```

## First Time Setup

If this is your first time running Flutter, you may need to:

1. **Accept licenses** (Android)
   ```bash
   flutter doctor --android-licenses
   ```

2. **Install dependencies** (check with flutter doctor)
   ```bash
   flutter doctor
   ```

3. **Enable web** (if needed)
   ```bash
   flutter config --enable-web
   ```

## Testing the App

### 1. Check Connection
- Open the app
- Look for green indicator showing "Connected to Backend"
- If red, make sure backend is running

### 2. View Live Courses
- You should see the list of courses on the main screen
- Each course shows status (scheduled/active/completed)

### 3. Start a Course as Host
- Click "Host" button on any course
- You'll be taken to the meeting room
- Camera and microphone will be requested

### 4. Join as Participant (Test with 2 devices/windows)
- In another window/device, use "Join Meeting" tab
- Enter the 6-digit meeting code from the host session
- Enter your name and click "Join Meeting"

### 5. Try Features
- **Chat**: Type messages in the chat panel
- **Audio**: Click microphone icon to mute/unmute
- **Video**: Click camera icon to enable/disable video
- **Participants**: See who's in the meeting
- **Leave**: Click "Leave" button to exit

## Troubleshooting

### Backend Not Connected
```bash
# Check if backend is running
curl http://localhost:3000/health

# Should return: {"status":"OK",...}
```

### Camera/Microphone Not Working
- **Web**: Grant permissions in browser
- **Android**: Grant permissions in app settings
- **iOS**: Grant permissions in app settings

### Dependencies Error
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

### Build Error
```bash
# Check Flutter installation
flutter doctor -v

# Update Flutter
flutter upgrade
```

## Development Mode

For development with hot reload:

```bash
# Run in debug mode
flutter run -d chrome --web-port 8080

# Make changes to code
# Press 'r' to hot reload
# Press 'R' to hot restart
# Press 'q' to quit
```

## Building for Production

### Web
```bash
flutter build web
# Output in: build/web/
# Deploy to any static hosting (Firebase, Netlify, etc.)
```

### Android APK
```bash
flutter build apk --release
# Output in: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Open in Xcode: open ios/Runner.xcworkspace
```

## Common Commands

```bash
# Run on Chrome
flutter run -d chrome

# Run tests
flutter test

# Format code
flutter format .

# Analyze code
flutter analyze

# List devices
flutter devices

# Clean build
flutter clean
```

## Project Structure Quick Reference

```
lib/
├── main.dart              # App entry
├── models/                # Data models
├── services/              # API & Socket.IO
├── screens/               # Main screens
└── widgets/               # Reusable widgets
```

## Next Steps

1. ✅ Explore the code in `lib/` directory
2. ✅ Read the full [README.md](README.md)
3. ✅ Check [FLUTTER_IMPLEMENTATION.md](../FLUTTER_IMPLEMENTATION.md) for React comparison
4. ✅ Customize the UI to match your branding
5. ✅ Add new features as needed

## Support

- Flutter Issues: Check `flutter doctor` output
- Backend Issues: See main project README
- Feature Requests: Open an issue on GitHub

## Tips

- Use hot reload (`r` key) for fast development
- Test on multiple platforms early
- Use Flutter DevTools for debugging
- Keep dependencies updated: `flutter pub upgrade`

Happy coding! 🎉
