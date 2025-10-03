# Beauty LMS - Video Conferencing System

A comprehensive Learning Management System with integrated video conferencing, real-time chat, and course management capabilities. Built with a modern tech stack supporting both React (web) and Flutter (cross-platform) frontends.

## 🎯 Overview

Beauty LMS provides a complete solution for online education with live video courses, real-time interaction, and comprehensive course management. The system includes:

- **Backend**: Node.js + Express + Socket.IO + MediaSoup
- **Frontend Options**:
  - **React**: Web-based interface (TypeScript)
  - **Flutter**: Cross-platform (Mobile, Web, Desktop)

## ✨ Features

### Core Features
- 🎥 **Video Conferencing**: Multi-participant video calls with WebRTC
- 💬 **Real-time Chat**: Instant messaging during courses
- 👥 **Participant Management**: Track and manage attendees
- 📊 **Course Management**: Create, start, and complete courses
- 🎤 **Audio/Video Controls**: Mute/unmute, camera on/off
- 📹 **Recording**: Automatic course recording with FFmpeg
- 🔄 **Real-time Updates**: Socket.IO for live synchronization
- 🔐 **Authentication**: Firebase integration (with mock fallback)

### Advanced Features
- **SFU Architecture**: Scalable video distribution with MediaSoup
- **Meeting Codes**: Secure 6-digit meeting access codes
- **Course Lifecycle**: Scheduled → Active → Completed states
- **Multi-platform**: Web, iOS, Android, Desktop support
- **Responsive Design**: Adapts to different screen sizes

## 🚀 Quick Start

### Prerequisites

- **Node.js** (v14+)
- **npm** or **yarn**
- **FFmpeg** (for recording)
- **Flutter SDK** (for Flutter frontend only)

### 1. Backend Setup

```bash
cd backend
npm install
npm start
```

Backend runs on `http://localhost:3000`

### 2. Frontend Setup

#### Option A: React Frontend (Web)

```bash
cd frontend
npm install
npm start
```

React app runs on `http://localhost:3001`

#### Option B: Flutter Frontend (Cross-platform)

```bash
cd flutter_frontend
flutter pub get
flutter run -d chrome  # or android, ios, etc.
```

See [Flutter Frontend README](flutter_frontend/README.md) for details.

## 📁 Project Structure

```
Beautylms/
├── backend/                    # Node.js backend
│   ├── server.js              # Main server file
│   ├── controllers/           # Business logic
│   ├── routes/                # API routes
│   └── config/                # Configuration
│
├── frontend/                   # React frontend
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── services/          # API & Socket services
│   │   └── App.tsx            # Main app component
│   └── package.json
│
├── flutter_frontend/           # Flutter frontend
│   ├── lib/
│   │   ├── models/            # Data models
│   │   ├── services/          # API & Socket services
│   │   ├── screens/           # App screens
│   │   └── widgets/           # Reusable widgets
│   └── pubspec.yaml
│
├── scripts/                    # Utility scripts
└── recordings/                 # Course recordings
```

## 🏗️ Architecture

### Backend Architecture

```
┌─────────────┐
│   Express   │ ← HTTP/REST API
│   Server    │
└─────────────┘
      │
      ├─────────┬──────────┬──────────┐
      ▼         ▼          ▼          ▼
  ┌────────┐ ┌─────┐  ┌────────┐ ┌────────┐
  │Firebase│ │Redis│  │Socket  │ │MediaSoup│
  │  (DB)  │ │Cache│  │  .IO   │ │ (WebRTC)│
  └────────┘ └─────┘  └────────┘ └────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   FFmpeg    │
                    │ (Recording) │
                    └─────────────┘
```

### Frontend Options

```
┌──────────────────────────────────────┐
│         React Frontend (Web)          │
│  ┌──────────────────────────────┐    │
│  │  Components (TypeScript)      │    │
│  │  - Video conferencing         │    │
│  │  - Chat interface            │    │
│  │  - Course management         │    │
│  └──────────────────────────────┘    │
└──────────────────────────────────────┘
                  OR
┌──────────────────────────────────────┐
│    Flutter Frontend (Cross-platform)  │
│  ┌──────────────────────────────┐    │
│  │  Screens & Widgets (Dart)    │    │
│  │  - Mobile optimized          │    │
│  │  - Material Design           │    │
│  │  - Platform adaptive         │    │
│  └──────────────────────────────┘    │
└──────────────────────────────────────┘
```

## 🎨 Frontend Comparison

| Feature | React Frontend | Flutter Frontend |
|---------|---------------|------------------|
| **Platform** | Web only | Mobile, Web, Desktop |
| **Language** | TypeScript | Dart |
| **UI Framework** | React + CSS | Material Design |
| **Hot Reload** | ✅ | ✅ |
| **Native Apps** | ❌ | ✅ |
| **Performance** | Good | Excellent |
| **Bundle Size** | Moderate | Small (native) |

See [FLUTTER_IMPLEMENTATION.md](FLUTTER_IMPLEMENTATION.md) for detailed comparison.

## 📚 Documentation

- **[FLUTTER_IMPLEMENTATION.md](FLUTTER_IMPLEMENTATION.md)**: React vs Flutter comparison
- **[Flutter README](flutter_frontend/README.md)**: Flutter setup and usage
- **[Flutter QUICKSTART](flutter_frontend/QUICKSTART.md)**: 5-minute setup guide
- **[Flutter ARCHITECTURE](flutter_frontend/ARCHITECTURE.md)**: Technical architecture
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)**: Backend implementation
- **[WEBRTC_TESTING_GUIDE.md](WEBRTC_TESTING_GUIDE.md)**: WebRTC testing guide

## 🔧 API Endpoints

### Health Check
- `GET /health` - Check server status

### Live Courses
- `GET /api/live_courses` - Get all courses
- `GET /api/live_courses/:id` - Get specific course
- `POST /api/live_courses/:id/start` - Start course
- `POST /api/live_courses/:id/complete` - Complete course

### Meetings
- `POST /api/meetings/join` - Join meeting
- `GET /api/meetings/:code/participants` - Get participants

### Socket.IO Events
- `join-meeting` - Join meeting room
- `leave-meeting` - Leave meeting room
- `chat-message` - Send/receive chat messages
- `participant-joined` - Participant joined notification
- `participant-left` - Participant left notification
- `toggle-audio` - Audio state change
- `toggle-video` - Video state change

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm test
```

### React Frontend Tests
```bash
cd frontend
npm test
```

### Flutter Tests
```bash
cd flutter_frontend
flutter test
```

### Integration Tests
```bash
node scripts/test_flutter_integration.js
```

## 🚢 Deployment

### Backend
```bash
cd backend
npm install
npm start
```

### React Frontend
```bash
cd frontend
npm run build
# Deploy build/ folder to static hosting
```

### Flutter Frontend

**Web**
```bash
flutter build web
# Deploy build/web/ to static hosting
```

**Android**
```bash
flutter build apk
# Distribute APK or upload to Play Store
```

**iOS**
```bash
flutter build ios
# Upload to App Store via Xcode
```

## 🔒 Security

- Firebase Authentication (production)
- Mock authentication (development)
- HTTPS required for WebRTC in production
- Secure meeting codes
- Permission-based access control

## 🌐 Environment Variables

Create `.env` file in backend:

```env
PORT=3000
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_PRIVATE_KEY=your-private-key
NODE_ENV=development
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 👥 Authors

- Beauty LMS Team

## 🙏 Acknowledgments

- MediaSoup for WebRTC SFU
- Socket.IO for real-time communication
- Flutter team for cross-platform framework
- React team for web framework
- FFmpeg for recording capabilities

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Check documentation in `/docs`
- Review troubleshooting guides

## 🎯 Roadmap

- [ ] Enhanced recording features
- [ ] Screen sharing support
- [ ] Breakout rooms
- [ ] Whiteboard integration
- [ ] Mobile app enhancements
- [ ] Advanced analytics
- [ ] Integration with LMS platforms

## 🏆 Features Highlights

### React Frontend
- Modern TypeScript codebase
- Responsive web design
- Chrome/Firefox/Safari support
- Desktop optimized

### Flutter Frontend
- Single codebase for all platforms
- Native performance
- Material Design
- iOS/Android/Web/Desktop support

Both frontends connect to the same backend API, allowing you to choose based on your needs!

---

**Made with ❤️ for online education**
