import 'package:flutter/material.dart';
import 'live_courses_list_screen.dart';
import 'meeting_joiner_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isConnected = false;
  String _connectionStatus = 'Checking...';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final response = await ApiService.healthCheck();
    setState(() {
      _isConnected = response.success;
      _connectionStatus = response.success 
          ? 'Connected to Backend' 
          : 'Backend Disconnected';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const LiveCoursesListScreen(),
      const MeetingJoinerScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎥 Beauty LMS'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.circle : Icons.circle_outlined,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  _connectionStatus,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _checkConnection,
                  tooltip: 'Refresh connection',
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.video_library),
            label: 'Live Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room),
            label: 'Join Meeting',
          ),
        ],
      ),
    );
  }
}
