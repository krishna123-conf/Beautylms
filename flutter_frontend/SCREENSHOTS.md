# Flutter Frontend UI Screenshots Guide

This document describes the user interface and visual design of the Flutter frontend.

## UI Overview

The Flutter frontend uses **Material Design 3** with a clean, modern aesthetic. The color scheme is primarily blue with intuitive icons and clear visual hierarchy.

## 1. Home Screen

### Layout
```
┌─────────────────────────────────────────┐
│ 🎥 Beauty LMS        🟢 Connected  [🔄] │ ← AppBar
├─────────────────────────────────────────┤
│                                         │
│         [Main Content Area]             │
│    (Live Courses or Join Meeting)       │
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│  📚 Live Courses  |  🚪 Join Meeting   │ ← Navigation Bar
└─────────────────────────────────────────┘
```

### Features
- **Top App Bar**: Shows app title and connection status
- **Green indicator**: Backend connected
- **Red indicator**: Backend disconnected
- **Refresh button**: Manually check connection
- **Bottom Navigation**: Switch between screens
- **Material Design**: Smooth animations and transitions

## 2. Live Courses List Screen

### Layout
```
┌─────────────────────────────────────────┐
│ 🎥 Beauty LMS        🟢 Connected  [🔄] │
├─────────────────────────────────────────┤
│ [Pull to Refresh]                       │
│                                         │
│ ┌───────────────────────────────────┐  │
│ │ ▶️ Introduction to Web Dev        │  │
│ │ Learn the basics of web...        │  │
│ │ 👤 John Doe  📚 Programming       │  │
│ │ ⏱️ 60 min    [ACTIVE]            │  │
│ │ 🔑 Code: 123456                   │  │
│ │ [🎯 Host]    [👥 Join]           │  │
│ └───────────────────────────────────┘  │
│                                         │
│ ┌───────────────────────────────────┐  │
│ │ 📅 Advanced React Patterns        │  │
│ │ Deep dive into React...           │  │
│ │ 👤 Jane Smith  📚 Web Dev         │  │
│ │ ⏱️ 90 min    [SCHEDULED]         │  │
│ │ [🎯 Host]    [👥 Join] (disabled)│  │
│ └───────────────────────────────────┘  │
│                                         │
├─────────────────────────────────────────┤
│  📚 Live Courses  |  🚪 Join Meeting   │
└─────────────────────────────────────────┘
```

### Course Card Elements
- **Course title**: Large, bold text
- **Description**: Secondary text
- **Instructor info**: Icon + name
- **Category**: Icon + category name
- **Duration**: Timer icon + minutes
- **Status badge**: 
  - 🟢 ACTIVE (green)
  - 🟠 SCHEDULED (orange)
  - ⚪ COMPLETED (gray)
- **Meeting code**: Shown only for active courses
- **Action buttons**:
  - **Host**: Blue filled button (always enabled)
  - **Join**: Outlined button (enabled only for active)

### Interactions
- **Pull down**: Refresh course list
- **Tap Host**: Start course as instructor
- **Tap Join**: Join course as participant
- **Loading state**: Shows spinner while connecting

## 3. Meeting Joiner Screen

### Layout
```
┌─────────────────────────────────────────┐
│ 🎥 Beauty LMS        🟢 Connected  [🔄] │
├─────────────────────────────────────────┤
│                                         │
│                                         │
│        ┌─────────────────────┐         │
│        │                     │         │
│        │      🚪             │         │
│        │   (64x64 icon)      │         │
│        │                     │         │
│        │   Join Meeting      │         │
│        │                     │         │
│        │ ┌─────────────────┐ │         │
│        │ │ Meeting Code    │ │         │
│        │ │ [_____________] │ │         │
│        │ └─────────────────┘ │         │
│        │                     │         │
│        │ ┌─────────────────┐ │         │
│        │ │ Your Name       │ │         │
│        │ │ [Test Particip] │ │         │
│        │ └─────────────────┘ │         │
│        │                     │         │
│        │  [🎯 Join Meeting]  │         │
│        │                     │         │
│        └─────────────────────┘         │
│                                         │
├─────────────────────────────────────────┤
│  📚 Live Courses  |  🚪 Join Meeting   │
└─────────────────────────────────────────┘
```

### Features
- **Centered card**: Clean, focused design
- **Large icon**: Visual focal point
- **Text fields**:
  - Meeting Code: 6-digit numeric input
  - Your Name: Text input with default value
- **Input validation**:
  - Meeting code must be 6 digits
  - Name is required
- **Join button**: 
  - Blue filled button
  - Disabled when form invalid
  - Shows loading spinner when joining

## 4. Meeting Room Screen

### Layout (Landscape optimized)
```
┌─────────────────────────────────────────────────────────────┐
│ Course Name                                 [✅] [💬] [×]    │ ← AppBar
├─────────────────────────────────────┬───────────────────────┤
│                                     │ 👥 Participants (3)  🔄│
│         [Video Area]                ├───────────────────────┤
│                                     │ ┌───────────────────┐ │
│                                     │ │👤 John (Host) ⭐ │ │
│                                     │ │   Joined: 14:30   │ │
│    ┌─────────────┐                 │ │   🟢              │ │
│    │  [Remote    │                 │ └───────────────────┘ │
│    │   Video]    │                 │ ┌───────────────────┐ │
│    │             │                 │ │👤 Jane (You)      │ │
│    │  (Centered) │                 │ │   Joined: 14:32   │ │
│    │             │                 │ │   🟢              │ │
│    └─────────────┘                 │ └───────────────────┘ │
│                                     ├───────────────────────┤
│  ┌──────┐                          │ 💬 Chat              │
│  │Local │ You (Camera)              ├───────────────────────┤
│  │Video │                           │ Jane: Hi everyone!    │
│  └──────┘                           │ John: Welcome!        │
│                                     │                       │
├─────────────────────────────────────┤ [Type message...] [→]│
│    [🎤] [📷] [🔴 Leave]            │                       │
└─────────────────────────────────────┴───────────────────────┘
```

### Main Components

#### Video Area
- **Black background**: Professional look
- **Remote video**: Centered in main area
- **Local video**: 
  - Bottom-right corner
  - 160x120px
  - White border
  - Mirrored view
- **Label overlay**: Shows "You (Camera)" or "You (Camera Off)"
- **Placeholder**: When no remote video, shows participant count

#### Control Bar (Bottom)
- **Microphone button**: 
  - White when enabled
  - Red when muted
  - Icon changes: 🎤 / 🎤🚫
- **Camera button**:
  - White when enabled
  - Red when disabled
  - Icon changes: 📷 / 📷🚫
- **Leave button**:
  - Red background
  - White text/icon
  - Shows "Leave" text

#### Participants Panel (Right side)
- **Header**: "👥 Participants (count)" with refresh button
- **List items**:
  - Avatar circle with initial
  - Name (bold if you)
  - "⭐" if host
  - "(You)" suffix if current user
  - Join time
  - Green online indicator 🟢
- **Card style**: Elevated with slight shadow
- **Highlight**: Your card has blue tint

#### Chat Panel (Right side, below participants)
- **Header**: "💬 Chat" with message count
- **Message bubbles**:
  - **Your messages**: 
    - Right-aligned
    - Blue background
    - White text
  - **Other messages**:
    - Left-aligned
    - Gray background
    - Black text
    - Sender name above
  - **Timestamp**: Small text below message
- **Input area**:
  - Text field with rounded border
  - Send button (→) on right
  - Sends on Enter key

### Color Scheme

#### Primary Colors
- **Primary Blue**: #2196F3
- **Success Green**: #4CAF50
- **Error Red**: #F44336
- **Warning Orange**: #FF9800
- **Gray Background**: #F5F5F5

#### Status Colors
- **Active**: Green (#4CAF50)
- **Scheduled**: Orange (#FF9800)
- **Completed**: Gray (#9E9E9E)
- **Online**: Green dot (#4CAF50)

### Typography

- **Headline**: 24sp, Bold
- **Title**: 18sp, Semi-bold
- **Body**: 14sp, Regular
- **Caption**: 12sp, Regular
- **Button**: 14sp, Medium

### Animations

1. **Page transitions**: Slide animation
2. **Button press**: Ripple effect (Material)
3. **Loading**: Circular progress indicator
4. **Refresh**: Pull-down animation
5. **New message**: Fade-in from bottom
6. **Participant join**: Slide-in animation

### Responsive Design

#### Mobile Portrait (< 600px width)
- Single column layout
- Chat/participants as bottom sheet
- Full-width video
- Stacked controls

#### Tablet (600-900px width)
- Side panel 300px width
- Main content flexible
- Larger touch targets

#### Desktop (> 900px width)
- Side panel 350px width
- Optimized for landscape
- Keyboard shortcuts enabled

### Accessibility

- **Semantic labels**: All interactive elements
- **Screen reader support**: Proper announcements
- **High contrast mode**: Supported
- **Large text**: Scales properly
- **Color blind friendly**: Icons + text labels

### Error States

#### No Connection
```
┌─────────────────────────────────┐
│         🔴                      │
│    Backend Disconnected         │
│                                 │
│  Cannot connect to server       │
│  Please check backend is        │
│  running and try again.         │
│                                 │
│      [🔄 Retry]                 │
└─────────────────────────────────┘
```

#### No Courses
```
┌─────────────────────────────────┐
│         📭                      │
│    No Courses Available         │
│                                 │
│  There are no courses to        │
│  display at this time.          │
│                                 │
│      [🔄 Refresh]               │
└─────────────────────────────────┘
```

#### Camera/Mic Permission Denied
```
┌─────────────────────────────────┐
│         🎥🎤                    │
│  Permission Required            │
│                                 │
│  Please grant camera and        │
│  microphone permissions to      │
│  join video calls.              │
│                                 │
│     [Open Settings]             │
└─────────────────────────────────┘
```

### Loading States

#### Initial Load
- Full-screen circular progress indicator
- Text: "Loading..."

#### Refresh
- Pull-down gesture
- Circular indicator at top

#### Connecting to Meeting
- Button shows inline spinner
- Text: "Connecting..."

#### Sending Message
- Send button disabled
- Brief spinner

## Platform-Specific Variations

### Android
- Material Design ripple effects
- System back button support
- Android-style navigation

### iOS
- Cupertino-style transitions
- Swipe back gesture
- iOS-style alerts and dialogs

### Web
- Mouse hover effects
- Keyboard navigation
- Browser-optimized layouts

### Desktop
- Larger window support
- Menu bar integration
- Keyboard shortcuts

## Dark Mode Support

The app respects system theme preference:

#### Dark Theme Colors
- **Background**: #121212
- **Surface**: #1E1E1E
- **Primary**: #90CAF9
- **Text**: #FFFFFF / #E0E0E0

## Summary

The Flutter frontend provides:
- ✅ Clean, modern Material Design
- ✅ Intuitive navigation
- ✅ Clear visual hierarchy
- ✅ Responsive layouts
- ✅ Smooth animations
- ✅ Accessibility support
- ✅ Platform-adaptive UI
- ✅ Consistent with React frontend functionality

The UI is designed to be familiar to users of the React frontend while leveraging Flutter's Material Design strengths.
