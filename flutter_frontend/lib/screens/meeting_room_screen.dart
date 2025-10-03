import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/live_course.dart';
import '../models/participant.dart';
import '../models/chat_message.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../widgets/chat_panel.dart';
import '../widgets/participants_list.dart';

class MeetingRoomScreen extends StatefulWidget {
  final LiveCourse course;
  final Participant participant;

  const MeetingRoomScreen({
    super.key,
    required this.course,
    required this.participant,
  });

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  final SocketService _socketService = SocketService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final List<RTCVideoRenderer> _remoteRenderers = [];
  
  MediaStream? _localStream;
  List<Participant> _participants = [];
  List<ChatMessage> _chatMessages = [];
  
  bool _isChatVisible = true;
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isInitializing = true;
  String _connectionStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _initializeRoom();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _initializeRoom() async {
    try {
      // Initialize video renderers
      await _localRenderer.initialize();

      // Initialize local media (camera and microphone)
      await _initializeLocalMedia();

      // Connect to Socket.IO
      _socketService.connect();

      // Set up event handlers
      _setupSocketHandlers();

      // Join the meeting room
      if (widget.course.meetingCode != null) {
        _socketService.joinMeetingRoom(
          widget.course.meetingCode!,
          widget.participant.name,
          widget.participant.id,
          widget.participant.isHost,
        );
      }

      // Load participants
      await _loadParticipants();

      setState(() {
        _isInitializing = false;
        _connectionStatus = 'Connected';
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _connectionStatus = 'Connection Failed';
      });
      _showError('Failed to initialize room: $e');
    }
  }

  Future<void> _initializeLocalMedia() async {
    try {
      final constraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print('Error accessing media devices: $e');
      _showError('Could not access camera/microphone. Please check permissions.');
    }
  }

  void _setupSocketHandlers() {
    _socketService.onParticipantsUpdate = (participants) {
      setState(() {
        _participants = participants;
      });
    };

    _socketService.onParticipantJoined = (participant) {
      setState(() {
        if (!_participants.any((p) => p.id == participant.id)) {
          _participants.add(participant);
        }
      });
      _showInfo('${participant.name} joined');
    };

    _socketService.onParticipantLeft = (participantId) {
      setState(() {
        _participants.removeWhere((p) => p.id == participantId);
      });
    };

    _socketService.onChatMessage = (message) {
      setState(() {
        _chatMessages.add(message);
      });
    };

    _socketService.onCourseEnded = () {
      _showInfo('Course has ended');
      Navigator.of(context).pop();
    };
  }

  Future<void> _loadParticipants() async {
    if (widget.course.meetingCode != null) {
      final response = await ApiService.getParticipants(widget.course.meetingCode!);
      if (response.success && response.data != null) {
        setState(() {
          _participants = response.data!;
        });
      }
    }
  }

  void _toggleAudio() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final enabled = !_isAudioEnabled;
        audioTracks[0].enabled = enabled;
        setState(() {
          _isAudioEnabled = enabled;
        });
        
        if (widget.course.meetingCode != null) {
          _socketService.toggleAudio(
            widget.course.meetingCode!,
            widget.participant.id,
            enabled,
          );
        }
      }
    }
  }

  void _toggleVideo() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final enabled = !_isVideoEnabled;
        videoTracks[0].enabled = enabled;
        setState(() {
          _isVideoEnabled = enabled;
        });
        
        if (widget.course.meetingCode != null) {
          _socketService.toggleVideo(
            widget.course.meetingCode!,
            widget.participant.id,
            enabled,
          );
        }
      }
    }
  }

  void _sendChatMessage(String message) {
    if (widget.course.meetingCode != null && message.isNotEmpty) {
      _socketService.sendChatMessage(
        widget.course.meetingCode!,
        widget.participant.name,
        message,
      );
    }
  }

  Future<void> _leaveMeeting() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Meeting'),
        content: const Text('Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.course.meetingCode != null) {
        _socketService.leaveMeetingRoom(
          widget.course.meetingCode!,
          widget.participant.id,
        );
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _completeCourse() async {
    if (!widget.participant.isHost) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Course'),
        content: const Text('This will end the course for all participants. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.completeCourse(widget.course.id);
      if (response.success) {
        _showInfo('Course completed successfully');
        Navigator.of(context).pop();
      } else {
        _showError(response.error ?? 'Failed to complete course');
      }
    }
  }

  void _cleanup() {
    _localStream?.dispose();
    _localRenderer.dispose();
    for (var renderer in _remoteRenderers) {
      renderer.dispose();
    }
    if (widget.course.meetingCode != null) {
      _socketService.leaveMeetingRoom(
        widget.course.meetingCode!,
        widget.participant.id,
      );
    }
    _socketService.disconnect();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInfo(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.name),
            Text(
              _connectionStatus,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (widget.participant.isHost)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _completeCourse,
              tooltip: 'Complete Course',
            ),
          IconButton(
            icon: Icon(_isChatVisible ? Icons.chat : Icons.chat_bubble_outline),
            onPressed: () {
              setState(() {
                _isChatVisible = !_isChatVisible;
              });
            },
            tooltip: 'Toggle Chat',
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing meeting room...'),
                ],
              ),
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: Stack(
                            children: [
                              // Local video
                              if (_localStream != null)
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  width: 160,
                                  height: 120,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: RTCVideoView(
                                        _localRenderer,
                                        mirror: true,
                                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                      ),
                                    ),
                                  ),
                                ),
                              // Label for local video
                              Positioned(
                                bottom: 24,
                                right: 24,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'You (${_isVideoEnabled ? "Camera" : "Camera Off"})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              // Main video area
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.videocam_off,
                                      size: 64,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '${_participants.length} participant(s) in meeting',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Controls
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[900],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isAudioEnabled ? Icons.mic : Icons.mic_off,
                                color: _isAudioEnabled ? Colors.white : Colors.red,
                              ),
                              onPressed: _toggleAudio,
                              tooltip: _isAudioEnabled ? 'Mute' : 'Unmute',
                              iconSize: 32,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(
                                _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                                color: _isVideoEnabled ? Colors.white : Colors.red,
                              ),
                              onPressed: _toggleVideo,
                              tooltip: _isVideoEnabled ? 'Stop Video' : 'Start Video',
                              iconSize: 32,
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _leaveMeeting,
                              icon: const Icon(Icons.call_end),
                              label: const Text('Leave'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Side panel with participants and chat
                if (_isChatVisible)
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ParticipantsList(
                            participants: _participants,
                            currentParticipant: widget.participant,
                            onRefresh: _loadParticipants,
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          flex: 2,
                          child: ChatPanel(
                            messages: _chatMessages,
                            currentParticipant: widget.participant,
                            onSendMessage: _sendChatMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
