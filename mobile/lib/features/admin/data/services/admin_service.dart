import 'package:flutter/foundation.dart';
import 'package:voatmean_mobile/core/services/api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  /// Gets teachers from database
  Future<List<Map<String, dynamic>>> getTeachers() async {
    try {
      final response = await _apiService.dio.get('/api/admin/teachers');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('AdminService: Error fetching teachers: $e');
    }
    return [];
  }

  /// Creates and whitelists a teacher in the database
  Future<bool> createTeacher({
    required String fullName,
    required String email,
    String? gender,
    String? classId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/admin/teachers',
        data: {
          'full_name': fullName,
          'email': email,
          'gender': gender,
          if (classId != null && classId.isNotEmpty) 'class_id': classId,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('AdminService: Error creating teacher: $e');
      return false;
    }
  }

  /// Gets homeroom classes from database
  Future<List<Map<String, dynamic>>> getHomeroomClasses() async {
    try {
      final response = await _apiService.dio.get('/api/admin/homeroom-classes');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('AdminService: Error fetching homeroom classes: $e');
    }
    return [];
  }

  /// Creates a new homeroom class
  Future<bool> createHomeroomClass({
    required String className,
    required String academicYear,
    String? homeroomTeacherId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/admin/homeroom-classes',
        data: {
          'class_name': className,
          'academic_year': academicYear,
          'homeroom_teacher_id': homeroomTeacherId,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('AdminService: Error creating homeroom class: $e');
      return false;
    }
  }

  /// Gets subjects from database
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final response = await _apiService.dio.get('/api/admin/subjects');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint('AdminService: Error fetching subjects: $e');
    }
    return [];
  }

  /// Creates a subject
  Future<bool> createSubject(String subjectName) async {
    try {
      final response = await _apiService.dio.post(
        '/api/admin/subjects',
        data: {'subject_name': subjectName},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('AdminService: Error creating subject: $e');
      return false;
    }
  }

  /// Gets system-wide score formula config
  Future<Map<String, dynamic>?> getDefaultScoreFormula() async {
    try {
      final response = await _apiService.dio.get('/api/admin/score-formula/default');
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('AdminService: Error fetching default score formula: $e');
    }
    return null;
  }

  /// Updates system-wide default score formula config
  Future<bool> updateDefaultScoreFormula({
    required String mode,
    required double attendanceWeight,
    required double teacherScoreWeight,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/api/admin/score-formula/default',
        data: {
          'mode': mode,
          'attendance_weight': attendanceWeight,
          'teacher_score_weight': teacherScoreWeight,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('AdminService: Error updating default score formula: $e');
      return false;
    }
  }
}
