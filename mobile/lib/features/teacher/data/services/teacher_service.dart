import 'package:flutter/foundation.dart';
import 'package:voatmean_mobile/core/services/api_service.dart';

class TeacherService {
  static final TeacherService _instance = TeacherService._internal();
  factory TeacherService() => _instance;
  TeacherService._internal();

  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>>? _cachedSlots;
  final Map<String, List<Map<String, dynamic>>> _cachedStudentsMap = {};
  final Map<String, List<Map<String, dynamic>>> _cachedGradesMap = {};

  /// Gets the teacher's assigned timetable slots with instant caching
  Future<List<Map<String, dynamic>>> getMySlots({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSlots != null && _cachedSlots!.isNotEmpty) {
      return _cachedSlots!;
    }
    try {
      final response = await _apiService.dio.get('/api/timetable/mine');
      if (response.statusCode == 200 && response.data is List) {
        _cachedSlots = List<Map<String, dynamic>>.from(response.data);
        return _cachedSlots!;
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching my slots: $e');
    }
    return _cachedSlots ?? [];
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

  /// Gets students by class ID with caching
  Future<List<Map<String, dynamic>>> getStudentsByClass(String classId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedStudentsMap.containsKey(classId) && _cachedStudentsMap[classId]!.isNotEmpty) {
      return _cachedStudentsMap[classId]!;
    }
    try {
      final response = await _apiService.dio.get('/api/students/class/$classId');
      if (response.statusCode == 200 && response.data is List) {
        final list = List<Map<String, dynamic>>.from(response.data);
        _cachedStudentsMap[classId] = list;
        return list;
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching students via /students/class/: $e');
    }
    return _cachedStudentsMap[classId] ?? [];
  }

  /// Gets monthly student scores and attendance summary with caching
  Future<List<Map<String, dynamic>>> getMonthlyGrades({
    required String classId,
    required String subjectId,
    required String month,
    bool forceRefresh = false,
  }) async {
    final key = '$classId-$subjectId-$month';
    if (!forceRefresh && _cachedGradesMap.containsKey(key) && _cachedGradesMap[key]!.isNotEmpty) {
      return _cachedGradesMap[key]!;
    }
    try {
      final response = await _apiService.dio.get('/api/scores/monthly/$classId/$subjectId/$month');
      if (response.statusCode == 200 && response.data is List) {
        final list = List<Map<String, dynamic>>.from(response.data);
        _cachedGradesMap[key] = list;
        return list;
      }
    } catch (e) {
      debugPrint('TeacherService: Error fetching monthly grades via /monthly/: $e');
    }
    return _cachedGradesMap[key] ?? [];
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
