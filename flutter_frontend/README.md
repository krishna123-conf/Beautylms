# Beauty LMS Flutter Frontend

A Flutter-based mobile and web frontend for the Beauty LMS Video Conferencing System. This application provides the same functionality as the React frontend, built with Flutter for cross-platform compatibility.

## Features

- 📱 Cross-platform support (iOS, Android, Web, Desktop)
- 🎥 Video conferencing with WebRTC
- 💬 Real-time chat
- 👥 Participant management
- 🎯 Live course management
- 🔄 Real-time updates via Socket.IO
- 📊 Course status tracking
- 🎨 Material Design UI

## Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (included with Flutter)
- Beauty LMS Backend running on `http://localhost:3000`

## Installation

### 1. Install Flutter

Follow the official Flutter installation guide for your platform:
- [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

### 2. Verify Installation

```bash
flutter doctor
```

### 3. Get Dependencies

```bash
cd flutter_frontend
flutter pub get
```

## Running the Application

### Web

```bash
flutter run -d chrome
```

### Android

```bash
flutter run -d android
```

### iOS (macOS only)

```bash
flutter run -d ios
```

### Desktop

```bash
# Linux
flutter run -d linux

# macOS
flutter run -d macos

# Windows
flutter run -d windows
```

## Project Structure

```
flutter_frontend/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── live_course.dart
│   │   ├── participant.dart
│   │   └── chat_message.dart
│   ├── services/                 # API and Socket services
│   │   ├── api_service.dart      # REST API service
│   │   └── socket_service.dart   # Socket.IO service
│   ├── screens/                  # App screens
│   │   ├── home_screen.dart
│   │   ├── live_courses_list_screen.dart
│   │   ├── meeting_joiner_screen.dart
│   │   └── meeting_room_screen.dart
│   └── widgets/                  # Reusable widgets
│       ├── chat_panel.dart
│       └── participants_list.dart
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── web/                          # Web-specific files
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

## Features Comparison with React Frontend

| Feature | React Frontend | Flutter Frontend |
|---------|---------------|------------------|
| Live Courses List | ✅ | ✅ |
| Join Meeting | ✅ | ✅ |
| Create Course | ✅ | ✅ (via Host) |
| Video Conferencing | ✅ | ✅ |
| Chat | ✅ | ✅ |
| Participants List | ✅ | ✅ |
| Audio/Video Controls | ✅ | ✅ |
| Course Completion | ✅ | ✅ |
| Real-time Updates | ✅ | ✅ |
| Responsive Design | ✅ | ✅ |

## Configuration

### API Endpoint

The API endpoint is configured in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

For production or different environments, update this URL accordingly.

### Socket.IO Connection

The Socket.IO connection is configured in `lib/services/socket_service.dart`:

```dart
_socket = IO.io('http://localhost:3000', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});
```

## Dependencies

Key dependencies used in this project:

- `flutter_webrtc`: ^0.9.48 - WebRTC support for video conferencing
- `socket_io_client`: ^2.0.3+1 - Socket.IO client for real-time communication
- `http`: ^1.1.0 - HTTP client for API calls
- `provider`: ^6.1.1 - State management (if needed)
- `intl`: ^0.18.1 - Internationalization and date formatting

## Building for Production

### Web

```bash
flutter build web
```

The build output will be in `build/web/`.

### Android

```bash
flutter build apk
# or for app bundle
flutter build appbundle
```

### iOS

```bash
flutter build ios
```

## Troubleshooting

### Backend Connection Issues

1. Ensure the backend is running:
   ```bash
   cd backend
   npm start
   ```

2. Check the backend health:
   ```bash
   curl http://localhost:3000/health
   ```

3. Verify the API endpoint in the Flutter app matches your backend URL.

### WebRTC Issues

1. For web, ensure you're using HTTPS or localhost (required for camera/microphone access)
2. Check browser permissions for camera and microphone
3. On mobile, ensure app permissions are granted

### Dependencies Issues

```bash
flutter clean
flutter pub get
flutter pub upgrade
```

## Development

### Adding New Features

1. Models: Add new data models in `lib/models/`
2. Services: Add new API endpoints in `lib/services/api_service.dart`
3. Screens: Create new screens in `lib/screens/`
4. Widgets: Create reusable widgets in `lib/widgets/`

### Running Tests

```bash
flutter test
```

## Contributing

When contributing to the Flutter frontend:

1. Follow Flutter best practices
2. Use meaningful widget and variable names
3. Add comments for complex logic
4. Test on multiple platforms before submitting
5. Ensure code formatting: `flutter format .`
6. Run analysis: `flutter analyze`

## License

Same as the main Beauty LMS project.

## Support

For issues specific to the Flutter frontend, please check:
- Flutter documentation: https://docs.flutter.dev
- Flutter WebRTC: https://github.com/flutter-webrtc/flutter-webrtc
- Socket.IO Client: https://pub.dev/packages/socket_io_client

For backend-related issues, refer to the main project documentation.
