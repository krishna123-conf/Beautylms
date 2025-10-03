import 'package:flutter/material.dart';
import '../models/live_course.dart';
import '../models/participant.dart';
import '../services/api_service.dart';
import 'meeting_room_screen.dart';

class LiveCoursesListScreen extends StatefulWidget {
  const LiveCoursesListScreen({super.key});

  @override
  State<LiveCoursesListScreen> createState() => _LiveCoursesListScreenState();
}

class _LiveCoursesListScreenState extends State<LiveCoursesListScreen> {
  List<LiveCourse> _courses = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  String? _connectingCourseId;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses({bool isRefresh = false}) async {
    setState(() {
      if (isRefresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _error = null;
    });

    final response = await ApiService.getAllCourses();

    setState(() {
      _isLoading = false;
      _isRefreshing = false;
      if (response.success && response.data != null) {
        _courses = response.data!;
      } else {
        _error = response.error ?? 'Failed to load courses';
      }
    });
  }

  Future<void> _handleHostConnect(LiveCourse course) async {
    setState(() {
      _connectingCourseId = course.id;
    });

    try {
      // Start the course
      final startResponse = await ApiService.startCourse(
        course.id,
        course.instructorId,
        course.instructorName,
      );

      if (startResponse.success && startResponse.data != null) {
        final meetingCode = startResponse.data?['videoConferencing']?['meetingCode'];
        final meetingId = startResponse.data?['videoConferencing']?['meetingId'];

        final updatedCourse = LiveCourse(
          id: course.id,
          name: course.name,
          description: course.description,
          instructorId: course.instructorId,
          instructorName: course.instructorName,
          category: course.category,
          status: 'active',
          scheduledDateTime: course.scheduledDateTime,
          duration: course.duration,
          enrolledUsers: course.enrolledUsers,
          joinedUsers: course.joinedUsers,
          recordingEnabled: course.recordingEnabled,
          meetingCode: meetingCode,
          meetingId: meetingId,
          createdAt: course.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        );

        final hostParticipant = Participant(
          id: course.instructorId,
          name: course.instructorName,
          joinedAt: DateTime.now().toIso8601String(),
          isHost: true,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingRoomScreen(
                course: updatedCourse,
                participant: hostParticipant,
              ),
            ),
          ).then((_) => _loadCourses(isRefresh: true));
        }
      } else {
        _showError(startResponse.error ?? 'Failed to start course');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _connectingCourseId = null;
      });
    }
  }

  Future<void> _handleParticipantConnect(LiveCourse course) async {
    if (course.meetingCode == null) {
      _showError('Course is not active yet');
      return;
    }

    setState(() {
      _connectingCourseId = course.id;
    });

    try {
      final response = await ApiService.joinMeeting(
        course.meetingCode!,
        'Test Participant',
      );

      if (response.success && response.data != null) {
        final participantData = response.data?['participant'];
        final participant = Participant(
          id: participantData['id'] ?? 'participant_${DateTime.now().millisecondsSinceEpoch}',
          name: participantData['name'] ?? 'Test Participant',
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
          ).then((_) => _loadCourses(isRefresh: true));
        }
      } else {
        _showError(response.error ?? 'Failed to join meeting');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _connectingCourseId = null;
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.play_circle_filled;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadCourses,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _courses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No courses available'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _loadCourses(isRefresh: true),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadCourses(isRefresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          final isConnecting = _connectingCourseId == course.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(course.status),
                                        color: _getStatusColor(course.status),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          course.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (course.description != null)
                                    Text(
                                      course.description!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16),
                                      const SizedBox(width: 4),
                                      Text(course.instructorName),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.category, size: 16),
                                      const SizedBox(width: 4),
                                      Text(course.category),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${course.duration} minutes'),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(course.status)
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          course.status.toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(course.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (course.meetingCode != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.vpn_key, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Code: ${course.meetingCode}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: isConnecting
                                              ? null
                                              : () => _handleHostConnect(course),
                                          icon: isConnecting
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(Icons.star),
                                          label: Text(isConnecting
                                              ? 'Connecting...'
                                              : 'Host'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: isConnecting ||
                                                  course.status != 'active'
                                              ? null
                                              : () =>
                                                  _handleParticipantConnect(course),
                                          icon: isConnecting
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(Icons.group),
                                          label: Text(isConnecting
                                              ? 'Joining...'
                                              : 'Join'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
