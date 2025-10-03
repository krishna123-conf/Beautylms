# Flutter Frontend Architecture

## Overview

The Flutter frontend follows a clean, layered architecture with clear separation of concerns.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │  Screens │  │  Widgets │  │  Dialogs │  │ Layouts │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    Business Logic                        │
│  ┌──────────────────────┐  ┌────────────────────────┐  │
│  │  State Management    │  │   Event Handlers       │  │
│  │  (StatefulWidgets)   │  │                        │  │
│  └──────────────────────┘  └────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    Service Layer                         │
│  ┌──────────────┐  ┌────────────────┐  ┌────────────┐  │
│  │  API Service │  │ Socket Service │  │ WebRTC     │  │
│  └──────────────┘  └────────────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                            │
│  ┌──────────────┐  ┌────────────────┐  ┌────────────┐  │
│  │    Models    │  │  Repositories  │  │   Cache    │  │
│  └──────────────┘  └────────────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  External Services                       │
│  ┌──────────────┐  ┌────────────────┐  ┌────────────┐  │
│  │ Backend API  │  │   Socket.IO    │  │   Media    │  │
│  │ (REST/HTTP)  │  │   (WebSocket)  │  │  Devices   │  │
│  └──────────────┘  └────────────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Directory Structure

```
flutter_frontend/
│
├── lib/
│   ├── main.dart                           # App entry point & configuration
│   │
│   ├── models/                             # Data Models (Plain Dart classes)
│   │   ├── live_course.dart                # Course data model
│   │   ├── participant.dart                # Participant data model
│   │   └── chat_message.dart               # Chat message model
│   │
│   ├── services/                           # Service Layer (Business Logic)
│   │   ├── api_service.dart                # REST API calls
│   │   └── socket_service.dart             # Real-time Socket.IO
│   │
│   ├── screens/                            # Full-screen UI components
│   │   ├── home_screen.dart                # Main navigation screen
│   │   ├── live_courses_list_screen.dart   # Course listing
│   │   ├── meeting_joiner_screen.dart      # Join meeting interface
│   │   └── meeting_room_screen.dart        # Video conferencing room
│   │
│   └── widgets/                            # Reusable UI components
│       ├── chat_panel.dart                 # Chat interface widget
│       └── participants_list.dart          # Participants display widget
│
├── test/                                   # Unit & Widget tests
│
├── android/                                # Android platform files
├── ios/                                    # iOS platform files
├── web/                                    # Web platform files
│
├── pubspec.yaml                            # Dependencies & configuration
├── analysis_options.yaml                   # Linting rules
├── README.md                               # Documentation
├── QUICKSTART.md                           # Quick start guide
└── ARCHITECTURE.md                         # This file
```

## Component Responsibilities

### 1. Models (`lib/models/`)

**Purpose**: Define data structures

**Responsibilities**:
- Define properties and types
- JSON serialization/deserialization
- Data validation (basic)
- No business logic

**Example**:
```dart
class LiveCourse {
  final String id;
  final String name;
  // ... other properties
  
  factory LiveCourse.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 2. Services (`lib/services/`)

**Purpose**: Handle external communication and business logic

#### API Service (`api_service.dart`)
- REST API communication
- HTTP requests (GET, POST)
- Response parsing
- Error handling
- Timeout management

**Endpoints**:
- Health check
- Course management (CRUD)
- Meeting operations
- Participant management

#### Socket Service (`socket_service.dart`)
- WebSocket connection management
- Real-time event handling
- Event emission
- Callback management

**Events**:
- Join/leave meeting
- Chat messages
- Participant updates
- Audio/video toggles

### 3. Screens (`lib/screens/`)

**Purpose**: Full-screen UI components with state management

#### Home Screen
- Navigation between sections
- Backend connection status
- Tab management

#### Live Courses List Screen
- Display courses
- Filtering and sorting
- Join/host actions
- Pull to refresh

#### Meeting Joiner Screen
- Form input
- Validation
- Meeting code entry

#### Meeting Room Screen
- Video display
- WebRTC management
- Controls (audio/video)
- Real-time updates
- Chat integration
- Participants display

### 4. Widgets (`lib/widgets/`)

**Purpose**: Reusable UI components

#### Chat Panel
- Message display
- Input field
- Send functionality
- Auto-scroll

#### Participants List
- Participant display
- Status indicators
- Host identification
- Refresh capability

## Data Flow

### 1. API Call Flow

```
Screen/Widget
    ↓ (user action)
API Service
    ↓ (HTTP request)
Backend API
    ↓ (HTTP response)
API Service (parse)
    ↓ (Model object)
Screen/Widget (setState)
    ↓ (update UI)
User sees changes
```

### 2. Real-time Event Flow

```
Socket Service (connected)
    ↓ (listening)
Backend emits event
    ↓ (event received)
Socket Service (callback)
    ↓ (parsed data)
Screen/Widget (setState)
    ↓ (update UI)
User sees changes
```

### 3. User Action Flow

```
User interacts
    ↓
Widget handles event
    ↓
Service called
    ↓ (async operation)
Loading state shown
    ↓
Response received
    ↓
State updated
    ↓
UI re-rendered
```

## State Management

### Current: StatefulWidget + setState

```dart
class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;
  List<Item> _items = [];
  
  void _updateData() {
    setState(() {
      _isLoading = true;
    });
    // ... fetch data
    setState(() {
      _isLoading = false;
      _items = fetchedItems;
    });
  }
}
```

### Lifecycle Methods

```dart
@override
void initState() {
  super.initState();
  // Initialize state, start listeners
}

@override
void dispose() {
  // Clean up resources
  super.dispose();
}
```

## Communication Patterns

### 1. HTTP Communication (REST)

```dart
// GET request
final response = await ApiService.getAllCourses();
if (response.success && response.data != null) {
  // Use data
}

// POST request
final response = await ApiService.startCourse(id, instructorId, name);
```

### 2. WebSocket Communication (Socket.IO)

```dart
// Connect
socketService.connect();

// Listen to events
socketService.onChatMessage = (message) {
  setState(() {
    _messages.add(message);
  });
};

// Emit events
socketService.sendChatMessage(meetingCode, sender, message);
```

### 3. WebRTC (Video/Audio)

```dart
// Initialize local media
final stream = await navigator.mediaDevices.getUserMedia(constraints);
_localRenderer.srcObject = stream;

// Toggle audio/video
audioTrack.enabled = !audioTrack.enabled;
```

## Navigation

### Stack-based Navigation

```dart
// Push new screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MeetingRoomScreen(
      course: course,
      participant: participant,
    ),
  ),
);

// Pop back
Navigator.pop(context);
```

## Error Handling

### Service Layer

```dart
try {
  final response = await http.get(url).timeout(timeout);
  // Parse and return
  return ApiResponse(success: true, data: parsedData);
} catch (e) {
  return ApiResponse(success: false, error: e.toString());
}
```

### UI Layer

```dart
final response = await ApiService.getSomething();
if (response.success) {
  // Handle success
  setState(() { _data = response.data; });
} else {
  // Show error
  _showError(response.error ?? 'Unknown error');
}
```

## Performance Considerations

### 1. Widget Building
- Use `const` constructors where possible
- Minimize rebuilds with `const` widgets
- Use `ListView.builder` for long lists

### 2. Async Operations
- Always handle loading states
- Use timeouts for network calls
- Cancel operations in `dispose()`

### 3. Memory Management
- Dispose controllers and streams
- Clean up WebRTC resources
- Disconnect sockets when leaving

## Testing Strategy

### Unit Tests
```dart
test('LiveCourse fromJson parsing', () {
  final json = {...};
  final course = LiveCourse.fromJson(json);
  expect(course.id, equals('test123'));
});
```

### Widget Tests
```dart
testWidgets('ChatPanel sends message', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.enterText(find.byType(TextField), 'Hello');
  await tester.tap(find.byIcon(Icons.send));
  // Verify message sent
});
```

## Future Enhancements

### Potential Improvements
1. **State Management**: Implement Provider/Bloc for complex state
2. **Offline Support**: Add local caching with SQLite
3. **Push Notifications**: Firebase Cloud Messaging
4. **Internationalization**: Multi-language support
5. **Theming**: Dark mode and custom themes
6. **Analytics**: User behavior tracking
7. **Error Reporting**: Crashlytics integration

## Best Practices

### Code Organization
- One widget per file (for complex widgets)
- Group related files in subdirectories
- Use meaningful file and class names

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

### Documentation
- Document public APIs
- Add TODO comments for future work
- Keep README updated

## Development Workflow

1. **Create/Update Model** (if needed)
2. **Add/Update Service Method** (if needed)
3. **Implement UI Screen/Widget**
4. **Test Integration**
5. **Handle Errors**
6. **Add Loading States**
7. **Polish UI**
8. **Write Tests**

## Dependencies

### Core Dependencies
- `flutter`: Framework
- `http`: REST API calls
- `socket_io_client`: Real-time communication
- `flutter_webrtc`: Video conferencing
- `intl`: Date/time formatting

### Dev Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Linting rules

## Platform-Specific Code

### Android
- Permissions in `AndroidManifest.xml`
- Minimum SDK version

### iOS
- Permissions in `Info.plist`
- Camera usage descriptions

### Web
- Index.html configuration
- Service worker (optional)

## Conclusion

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Easy testing
- ✅ Maintainable code
- ✅ Scalable structure
- ✅ Reusable components

The simple state management approach is sufficient for the current app size and can be upgraded to more complex solutions as needed.
