import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_message.dart';
import '../models/participant.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  // Event callbacks
  Function(List<Participant>)? onParticipantsUpdate;
  Function(ChatMessage)? onChatMessage;
  Function(Participant)? onParticipantJoined;
  Function(String)? onParticipantLeft;
  Function()? onCourseEnded;

  bool get isConnected => _isConnected;

  void connect() {
    if (_socket != null && _isConnected) {
      return;
    }

    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.on('connect', (_) {
      print('Socket.IO connected');
      _isConnected = true;
    });

    _socket!.on('disconnect', (_) {
      print('Socket.IO disconnected');
      _isConnected = false;
    });

    _socket!.on('error', (error) {
      print('Socket.IO error: $error');
    });

    // Meeting room events
    _socket!.on('participant-joined', (data) {
      if (onParticipantJoined != null) {
        onParticipantJoined!(Participant.fromJson(data));
      }
    });

    _socket!.on('participant-left', (data) {
      if (onParticipantLeft != null) {
        onParticipantLeft!(data['participantId']);
      }
    });

    _socket!.on('participants-update', (data) {
      if (onParticipantsUpdate != null) {
        final participants = (data as List)
            .map((p) => Participant.fromJson(p))
            .toList();
        onParticipantsUpdate!(participants);
      }
    });

    _socket!.on('chat-message', (data) {
      if (onChatMessage != null) {
        onChatMessage!(ChatMessage.fromJson(data));
      }
    });

    _socket!.on('course-ended', (_) {
      if (onCourseEnded != null) {
        onCourseEnded!();
      }
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
    }
  }

  void joinMeetingRoom(
    String meetingCode,
    String participantName,
    String participantId,
    bool isHost,
  ) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join-meeting', {
        'meetingCode': meetingCode,
        'participantName': participantName,
        'participantId': participantId,
        'isHost': isHost,
      });
    }
  }

  void leaveMeetingRoom(String meetingCode, String participantId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave-meeting', {
        'meetingCode': meetingCode,
        'participantId': participantId,
      });
    }
  }

  void sendChatMessage(String meetingCode, String sender, String message) {
    if (_socket != null && _isConnected) {
      _socket!.emit('chat-message', {
        'meetingCode': meetingCode,
        'sender': sender,
        'message': message,
      });
    }
  }

  void toggleAudio(String meetingCode, String participantId, bool enabled) {
    if (_socket != null && _isConnected) {
      _socket!.emit('toggle-audio', {
        'meetingCode': meetingCode,
        'participantId': participantId,
        'enabled': enabled,
      });
    }
  }

  void toggleVideo(String meetingCode, String participantId, bool enabled) {
    if (_socket != null && _isConnected) {
      _socket!.emit('toggle-video', {
        'meetingCode': meetingCode,
        'participantId': participantId,
        'enabled': enabled,
      });
    }
  }
}
