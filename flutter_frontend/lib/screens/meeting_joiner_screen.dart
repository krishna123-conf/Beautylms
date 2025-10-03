import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../models/live_course.dart';
import '../services/api_service.dart';
import 'meeting_room_screen.dart';

class MeetingJoinerScreen extends StatefulWidget {
  const MeetingJoinerScreen({super.key});

  @override
  State<MeetingJoinerScreen> createState() => _MeetingJoinerScreenState();
}

class _MeetingJoinerScreenState extends State<MeetingJoinerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _meetingCodeController = TextEditingController();
  final _nameController = TextEditingController(text: 'Test Participant');
  bool _isLoading = false;

  @override
  void dispose() {
    _meetingCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _joinMeeting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.joinMeeting(
        _meetingCodeController.text,
        _nameController.text,
      );

      if (response.success && response.data != null) {
        final meetingData = response.data?['meeting'];
        final participantData = response.data?['participant'];

        // Create course from meeting data
        final course = LiveCourse(
          id: meetingData['meetingId'] ?? '',
          name: meetingData['title'] ?? 'Meeting',
          description: meetingData['description'],
          instructorId: meetingData['hostId'] ?? '',
          instructorName: meetingData['hostName'] ?? '',
          category: 'Meeting',
          status: 'active',
          scheduledDateTime: meetingData['createdAt'] ?? DateTime.now().toIso8601String(),
          duration: 60,
          enrolledUsers: [],
          recordingEnabled: false,
          meetingCode: _meetingCodeController.text,
          meetingId: meetingData['meetingId'],
          createdAt: meetingData['createdAt'] ?? DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        final participant = Participant(
          id: participantData['id'] ?? 'participant_${DateTime.now().millisecondsSinceEpoch}',
          name: participantData['name'] ?? _nameController.text,
          joinedAt: participantData['joinedAt'] ?? DateTime.now().toIso8601String(),
          isHost: false,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingRoomScreen(
                course: course,
                participant: participant,
              ),
            ),
          );
        }
      } else {
        _showError(response.error ?? 'Failed to join meeting');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Join Meeting',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _meetingCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Code',
                        hintText: 'Enter 6-digit meeting code',
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a meeting code';
                        }
                        if (value.length != 6) {
                          return 'Meeting code must be 6 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _joinMeeting,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(_isLoading ? 'Joining...' : 'Join Meeting'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
