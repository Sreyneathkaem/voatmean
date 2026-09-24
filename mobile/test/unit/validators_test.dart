import 'package:flutter_test/flutter_test.dart';
import 'package:voatmean_mobile/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('returns error message for null or empty email', () {
      expect(Validators.validateEmail(null), 'សូមបញ្ចូលអុីមែល');
      expect(Validators.validateEmail('   '), 'សូមបញ្ចូលអុីមែល');
    });

    test('returns error message for invalid email format', () {
      expect(Validators.validateEmail('invalid-email'), 'ទម្រង់អុីមែលមិនត្រឹមត្រូវ');
      expect(Validators.validateEmail('test@com'), 'ទម្រង់អុីមែលមិនត្រឹមត្រូវ');
    });

    test('returns null for valid email', () {
      expect(Validators.validateEmail('user@voatmean.edu.kh'), isNull);
      expect(Validators.validateEmail('sreyneathk24@gmail.com'), isNull);
    });
  });

  group('Validators - Password', () {
    test('returns error message for null or empty password', () {
      expect(Validators.validatePassword(null), 'សូមបញ្ចូលពាក្យសម្ងាត់');
      expect(Validators.validatePassword(''), 'សូមបញ្ចូលពាក្យសម្ងាត់');
    });

    test('returns error message for password shorter than 6 characters', () {
      expect(
        Validators.validatePassword('12345'),
        'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ',
      );
    });

    test('returns null for valid password', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('securePass123'), isNull);
    });
  });

  group('Validators - Role Detection', () {
    test('detects dual role correctly', () {
      expect(
        Validators.detectRoleFromEmail('admin.teacher@voatmean.edu.kh'),
        DetectedRole.dual,
      );
      expect(
        Validators.detectRoleFromEmail('sreyneathk24@gmail.com'),
        DetectedRole.dual,
      );
    });

    test('detects admin role correctly', () {
      expect(
        Validators.detectRoleFromEmail('admin@voatmean.edu.kh'),
        DetectedRole.admin,
      );
      expect(
        Validators.detectRoleFromEmail('principal@school.edu'),
        DetectedRole.admin,
      );
    });

    test('defaults to teacher role for standard email', () {
      expect(
        Validators.detectRoleFromEmail('teacher@voatmean.edu.kh'),
        DetectedRole.teacher,
      );
      expect(
        Validators.detectRoleFromEmail('john.doe@gmail.com'),
        DetectedRole.teacher,
      );
    });

    test('returns null for empty email string', () {
      expect(Validators.detectRoleFromEmail('   '), isNull);
    });
  });
}
