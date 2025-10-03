import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/live_course.dart';
import '../models/participant.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });
}

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(seconds: 10);

  // Health check
  static Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/health'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: json.decode(response.body),
        );
      } else {
        return ApiResponse(
          success: false,
          error: 'Health check failed',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Get all live courses
  static Future<ApiResponse<List<LiveCourse>>> getAllCourses() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/live_courses'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final courses = (data['data'] as List)
              .map((course) => LiveCourse.fromJson(course))
              .toList();
          return ApiResponse(
            success: true,
            data: courses,
          );
        }
      }
      return ApiResponse(
        success: false,
        error: 'Failed to get courses',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Get course by ID
  static Future<ApiResponse<LiveCourse>> getCourseById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/live_courses/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ApiResponse(
            success: true,
            data: LiveCourse.fromJson(data['data']),
          );
        }
      }
      return ApiResponse(
        success: false,
        error: 'Failed to get course',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Start live course
  static Future<ApiResponse<Map<String, dynamic>>> startCourse(
    String courseId,
    String instructorId,
    String instructorName,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/live_courses/$courseId/start'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'instructorId': instructorId,
              'instructorName': instructorName,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: data['data'],
          );
        }
      }
      return ApiResponse(
        success: false,
        error: 'Failed to start course',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Complete course
  static Future<ApiResponse<Map<String, dynamic>>> completeCourse(
      String courseId) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/live_courses/$courseId/complete'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: data['data'],
          );
        }
      }
      return ApiResponse(
        success: false,
        error: 'Failed to complete course',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Join meeting
  static Future<ApiResponse<Map<String, dynamic>>> joinMeeting(
    String meetingCode,
    String participantName,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/meetings/join'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'meetingCode': meetingCode,
              'participantName': participantName,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            data: data['data'],
          );
        }
      }
      return ApiResponse(
        success: false,
        error: 'Failed to join meeting',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Get participants
  static Future<ApiResponse<List<Participant>>> getParticipants(
      String meetingCode) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/meetings/$meetingCode/participants'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final participants = (data['data'] as List)
              .map((p) => Participant.fromJson(p))
              .toList();
          return ApiResponse(
            success: true,
            data: participants,
          );
        }
      }
      return ApiResponse(
        success: false,
        error: 'Failed to get participants',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}
