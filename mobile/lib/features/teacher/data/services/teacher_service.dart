import 'package:flutter/foundation.dart';
import 'package:voatmean_mobile/core/services/api_service.dart';

class TeacherService {
  final ApiService _apiService = ApiService();

  /// Gets the teacher's assigned timetable slots
  Future<List<Map<String, dynamic>>> getMySlots() async {
    try {
      final response = await _apiService.dio.get('/api/timetable/my-slots');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching my slots: $e');
    }
    return [];
  }

  /// Gets the student roster for a specific slot
  Future<List<Map<String, dynamic>>> getSlotRoster(String slotId) async {
    try {
      final response = await _apiService.dio.get('/api/attendance/slots/$slotId/roster');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching slot roster: $e');
    }
    return [];
  }

  /// Gets existing attendance records for a slot on a date
  Future<List<Map<String, dynamic>>> getSlotAttendance(String slotId, String date) async {
    try {
      final response = await _apiService.dio.get('/api/attendance/slots/$slotId/$date');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching slot attendance: $e');
    }
    return [];
  }

  /// Saves/updates attendance records in PostgreSQL database
  Future<bool> saveSlotAttendance({
    required String slotId,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/attendance/slots/$slotId/$date',
        data: {'records': records},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('TeacherService: Error saving slot attendance: $e');
      return false;
    }
  }

  /// Gets students by class ID
  Future<List<Map<String, dynamic>>> getStudentsByClass(String classId) async {
    try {
      final response = await _apiService.dio.get('/api/students/class/$classId');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching students by class: $e');
    }
    return [];
  }

  /// Gets monthly student scores and attendance summary for report screen
  Future<List<Map<String, dynamic>>> getMonthlyGrades({
    required String classId,
    required String subjectId,
    required String month,
  }) async {
    try {
      final response = await _apiService.dio.get('/api/scores/monthly/$classId/$subjectId/$month');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching monthly grades: $e');
    }
    return [];
  }

  /// Upserts a subject score for a student
  Future<bool> upsertSubjectScore({
    required String studentId,
    required String subjectId,
    required String classId,
    required String month,
    required double teacherScore,
    double maxScore = 100.0,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/scores/subject',
        data: {
          'student_id': studentId,
          'subject_id': subjectId,
          'class_id': classId,
          'month': month,
          'teacher_score': teacherScore,
          'max_score': maxScore,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('TeacherService: Error upserting subject score: $e');
      return false;
    }
  }
}
