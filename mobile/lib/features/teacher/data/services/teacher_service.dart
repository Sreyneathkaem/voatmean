import 'package:flutter/foundation.dart';
import 'package:voatmean_mobile/core/services/api_service.dart';

class TeacherService {
  final ApiService _apiService = ApiService();

  /// Gets the teacher's assigned timetable slots
  Future<List<Map<String, dynamic>>> getMySlots() async {
    try {
      final response = await _apiService.dio.get('/api/timetable/mine');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching my slots (/mine): $e');
      try {
        final fallback = await _apiService.dio.get('/api/timetable/my-slots');
        if (fallback.statusCode == 200 && fallback.data is List) {
          return List<Map<String, dynamic>>.from(fallback.data);
        }
      } catch (e2) {
        debugPrint('TeacherService: Error fetching my slots (/my-slots): $e2');
      }
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
      debugPrint('TeacherService: Error fetching students via /students/class/: $e');
      try {
        final fallback = await _apiService.dio.get('/api/students/$classId');
        if (fallback.statusCode == 200 && fallback.data is List) {
          return List<Map<String, dynamic>>.from(fallback.data);
        }
      } catch (e2) {
        debugPrint('TeacherService: Error fetching students via /students/: $e2');
      }
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
      debugPrint('TeacherService: Error fetching monthly grades via /monthly/: $e');
      try {
        final fallback = await _apiService.dio.get('/api/scores/final/$classId/$subjectId/$month');
        if (fallback.statusCode == 200 && fallback.data is List) {
          return List<Map<String, dynamic>>.from(fallback.data);
        }
      } catch (e2) {
        debugPrint('TeacherService: Error fetching monthly grades via /final/: $e2');
      }
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

  /// Gets the score formula and attendance deduction policy for a subject
  Future<Map<String, dynamic>?> getScoreFormula(String subjectId) async {
    try {
      final response = await _apiService.dio.get('/api/admin/score-formula/$subjectId');
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('TeacherService: Error getting score formula for $subjectId: $e');
    }
    return null;
  }

  /// Updates the score formula and attendance deduction policy for a subject
  Future<bool> updateScoreFormula({
    required String subjectId,
    required double attendanceWeight,
    required double teacherScoreWeight,
    double permissionDeduction = 30.0,
    double lateDeduction = 50.0,
    double absentDeduction = 100.0,
    String mode = 'weighted_blend',
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/api/admin/score-formula/$subjectId',
        data: {
          'mode': mode,
          'attendance_weight': attendanceWeight,
          'teacher_score_weight': teacherScoreWeight,
          'permission_deduction': permissionDeduction,
          'late_deduction': lateDeduction,
          'absent_deduction': absentDeduction,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('TeacherService: Error updating score formula for $subjectId: $e');
      return false;
    }
  }
}
