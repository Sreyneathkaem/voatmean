enum DetectedRole { admin, teacher, dual }

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'សូមបញ្ចូលអុីមែល';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'ទម្រង់អុីមែលមិនត្រឹមត្រូវ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'សូមបញ្ចូលពាក្យសម្ងាត់';
    }
    if (value.length < 6) {
      return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'សូមបញ្ចូល $fieldName';
    }
    return null;
  }

  // Automatic role resolution based on email string
  static DetectedRole? detectRoleFromEmail(String email) {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return null;

    if (clean.contains('dual') ||
        clean.contains('admin.teacher') ||
        clean.contains('teacher.admin') ||
        clean == 'admin.teacher@voatmean.edu.kh' ||
        clean == 'makra.seng@voatmean.edu.kh' ||
        (clean.contains('admin') && clean.contains('teacher'))) {
      return DetectedRole.dual;
    } else if (clean.contains('admin') ||
        clean.contains('principal') ||
        clean.contains('director') ||
        clean == 'admin@voatmean.edu.kh') {
      return DetectedRole.admin;
    } else {
      return DetectedRole.teacher;
    }
  }
}