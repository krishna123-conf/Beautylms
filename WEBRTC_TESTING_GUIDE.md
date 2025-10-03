# WebRTC Video/Audio Testing Guide

This guide explains how to test the video conferencing features in the Beauty LMS application.

## Features Implemented

### 1. Video/Audio Communication
- ✅ Host and participants can see each other via webcam
- ✅ Host and participants can hear each other
- ✅ High-quality video (720p at 30fps)
- ✅ Enhanced audio with echo cancellation, noise suppression, and auto gain control
- ✅ Real-time connection state monitoring

### 2. Media Controls
- ✅ Toggle microphone on/off
- ✅ Toggle camera on/off
- ✅ Visual indicators for enabled/disabled states
- ✅ Notifications to other participants when media state changes

### 3. Screen Sharing
- ✅ Host can share screen
- ✅ Screen sharing includes system audio (if available)
- ✅ Automatic fallback to camera when screen share ends
- ✅ Only hosts can initiate screen sharing

### 4. Real-time Features
- ✅ Live participant list updates
- ✅ Chat functionality with system notifications
- ✅ Connection status indicator
- ✅ Join/leave notifications

## Testing Instructions

### Prerequisites
1. Two devices or browsers (for testing peer-to-peer communication)
2. Camera and microphone permissions enabled
3. Backend server running on port 3000
4. Frontend server running on port 3001 (or configured port)

### Step 1: Start the Backend
```bash
cd backend
npm install
npm start
```
The backend will start on `http://localhost:3000`

### Step 2: Start the Frontend
```bash
cd frontend
npm install
npm start
```
The frontend will start on `http://localhost:3001`

### Step 3: Create a Live Course (Host)
1. Navigate to the "Live Courses" tab
2. Click "Create New Course"
3. Fill in the course details:
   - Name: "Test Video Call"
   - Description: "Testing video and audio"
   - Duration: 60 minutes
4. Click "Create Course"
5. Note the meeting code displayed
6. Click "Start as Host" to join the meeting

### Step 4: Join as Participant
1. Open a new browser tab/window or use a different device
2. Navigate to the frontend URL
3. Go to "Live Courses" tab
4. Find the course created in Step 3
5. Click "Join as Participant"
6. Enter your name when prompted

### Step 5: Test Video/Audio
#### On Both Devices:
- [ ] Verify local video is displayed in the small preview window (top-right)
- [ ] Verify remote video appears in the main video area
- [ ] Verify you can see the other participant's video
- [ ] Verify you can hear the other participant speaking
- [ ] Check console logs for WebRTC connection status

#### Connection States to Monitor:
Look for these console messages:
- `✅ Local media initialized`
- `📡 Creating offer for [participantId]`
- `📥 Received offer from [participantId]`
- `📤 Sending answer to [participantId]`
- `🧊 ICE connection state: connected`
- `🔗 Connection state: connected`
- `📺 Received remote stream from [participantId]`

### Step 6: Test Media Controls
#### Test Audio Toggle:
1. Click the "Mute" button on one device
2. Verify the button changes to "Unmute" 
3. Verify the other participant can't hear you anymore
4. Click "Unmute" and verify audio works again

#### Test Video Toggle:
1. Click the "Stop Video" button
2. Verify the button changes to "Start Video"
3. Verify your local video feed stops
4. Verify the other participant sees your video stop
5. Click "Start Video" and verify video resumes

### Step 7: Test Screen Sharing (Host Only)
1. On the host device, click "Share Screen"
2. Select a window/screen to share in the browser dialog
3. Allow screen sharing permission
4. Verify your local preview shows the screen
5. Verify the participant sees your shared screen
6. Click "Stop Sharing" 
7. Verify video returns to camera feed

#### Screen Sharing Features to Test:
- [ ] Screen share starts successfully
- [ ] Participant sees the shared screen
- [ ] System audio is transmitted (if sharing with audio)
- [ ] Screen share stops and camera resumes
- [ ] Screen share automatically stops when closing the shared window

### Step 8: Test Chat Functionality
1. Send a message from the host
2. Verify the message appears on the participant's side
3. Send a message from the participant
4. Verify the message appears on the host's side
5. Check system messages for join/leave events

### Step 9: Test Participant Management
1. Have a third person join the meeting
2. Verify all participants can see each other
3. Verify the participant count updates
4. Have one participant leave
5. Verify the participant list updates
6. Verify system message shows who left

## Troubleshooting

### No Video/Audio
1. **Check browser permissions**: Ensure camera/microphone are allowed
2. **Check console logs**: Look for error messages
3. **Verify media initialization**: Should see "✅ Local media initialized"
4. **Check ICE connection**: Should reach "connected" state
5. **Try refreshing**: Sometimes a page refresh resolves permission issues

### Audio Issues
- Ensure microphone is not muted in system settings
- Check if audio tracks are being added to peer connection (console logs)
- Verify remote video element is not muted (should not have `muted` attribute)
- Check browser's audio output settings

### Video Issues
- Ensure camera is not being used by another application
- Check if video tracks are being transmitted
- Verify video element has proper `srcObject` set
- Look for "📺 Received remote stream" in console

### Screen Sharing Issues
- Only hosts can share screen
- Ensure you're using a browser that supports `getDisplayMedia`
- Check if video track replacement is successful in console logs
- Verify the screen share button is not disabled

### Connection Issues
- Verify backend is running and accessible
- Check Socket.IO connection status (green dot in meeting header)
- Ensure STUN servers are accessible
- Check firewall settings if on corporate network
- Look for ICE connection failures in console

## Expected Console Output

### Successful Connection Flow:
```
✅ Connected to Socket.IO server
👥 New participant [name] joined meeting [code]
✅ Local media initialized
📹 Video tracks: 1
🎤 Audio tracks: 1
📡 Creating offer for [participantId]
➕ Adding video track to peer connection for [participantId]
➕ Adding audio track to peer connection for [participantId]
📤 Sending offer to [participantId]
🧊 Sending ICE candidate to [participantId]
📥 Received answer from [participantId]
✅ Set remote description for [participantId]
🧊 Added ICE candidate from [participantId]
🔗 Connection state for [participantId]: connected
🧊 ICE connection state for [participantId]: connected
📺 Received remote stream from [participantId]
✅ Attached stream to video element for: [participantId]
```

## Known Limitations

1. **Browser Compatibility**: 
   - Best tested on Chrome/Edge (Chromium-based browsers)
   - Firefox may have different behavior
   - Safari may require additional configuration

2. **Network Requirements**:
   - Stable internet connection required
   - High bandwidth recommended for quality video
   - Firewall may block WebRTC traffic

3. **Device Requirements**:
   - Working camera and microphone
   - Modern browser with WebRTC support
   - Sufficient processing power for video encoding

## Architecture Overview

### Frontend Components:
- **MeetingRoom.tsx**: Main meeting room UI component
- **webrtcService.ts**: Handles WebRTC peer connections
- **socketService.ts**: Manages Socket.IO signaling

### Backend Components:
- **socketController.js**: Handles WebRTC signaling and events
- **meetingController.js**: Manages meeting rooms and participants

### WebRTC Flow:
1. Participant A joins → initializes local media
2. Participant B joins → receives current participants list
3. Participant A receives "participant-joined" event
4. Participant A creates offer and sends to B
5. Participant B receives offer, creates answer
6. B sends answer back to A
7. ICE candidates are exchanged
8. Peer connection established
9. Media streams flow bidirectionally

## Success Criteria

The implementation is successful if:
- [x] Host can see and hear all participants
- [x] Participants can see and hear the host
- [x] Participants can see and hear each other
- [x] Screen sharing works for the host
- [x] Media controls (mute/unmute) work correctly
- [x] Chat messages are delivered in real-time
- [x] Participant list updates dynamically
- [x] Connection is stable without frequent drops
- [x] Audio quality is clear without echo
- [x] Video quality is smooth (no excessive lag)
