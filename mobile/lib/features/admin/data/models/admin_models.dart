class ClassItem {
  final String id;
  final String grade;
  final String gradeKhmer;
  final String subject;
  final String subjectKhmer;
  final String academicYear;
  final String assignedTeacherId;
  final String assignedTeacherName;
  final String assignedTeacherKhmer;
  final int hoursPerWeek;
  final int totalStudents;
  final String status;

  ClassItem({
    required this.id,
    required this.grade,
    required this.gradeKhmer,
    required this.subject,
    required this.subjectKhmer,
    required this.academicYear,
    required this.assignedTeacherId,
    required this.assignedTeacherName,
    required this.assignedTeacherKhmer,
    required this.hoursPerWeek,
    required this.totalStudents,
    this.status = 'active',
  });

  ClassItem copyWith({
    String? grade,
    String? gradeKhmer,
    String? subject,
    String? subjectKhmer,
    String? academicYear,
    String? assignedTeacherId,
    String? assignedTeacherName,
    String? assignedTeacherKhmer,
    int? hoursPerWeek,
  }) {
    return ClassItem(
      id: id,
      grade: grade ?? this.grade,
      gradeKhmer: gradeKhmer ?? this.gradeKhmer,
      subject: subject ?? this.subject,
      subjectKhmer: subjectKhmer ?? this.subjectKhmer,
      academicYear: academicYear ?? this.academicYear,
      assignedTeacherId: assignedTeacherId ?? this.assignedTeacherId,
      assignedTeacherName: assignedTeacherName ?? this.assignedTeacherName,
      assignedTeacherKhmer: assignedTeacherKhmer ?? this.assignedTeacherKhmer,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      totalStudents: totalStudents,
      status: status,
    );
  }
}

class TeacherModel {
  final String id;
  final String name;
  final String nameKhmer;
  final String gender; // 'M' | 'F'
  final String phone;
  final String email;
  final String subject;
  final String subjectKhmer;
  final List<String> assignedClasses;
  final int teachingHoursPerWeek;
  final String status;
  final String avatarUrl;

  TeacherModel({
    required this.id,
    required this.name,
    required this.nameKhmer,
    required this.gender,
    required this.phone,
    required this.email,
    required this.subject,
    required this.subjectKhmer,
    required this.assignedClasses,
    required this.teachingHoursPerWeek,
    this.status = 'active',
    required this.avatarUrl,
  });

  TeacherModel copyWith({
    String? name,
    String? nameKhmer,
    String? gender,
    String? phone,
    String? email,
    String? subject,
    String? subjectKhmer,
    List<String>? assignedClasses,
    int? teachingHoursPerWeek,
  }) {
    return TeacherModel(
      id: id,
      name: name ?? this.name,
      nameKhmer: nameKhmer ?? this.nameKhmer,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      subjectKhmer: subjectKhmer ?? this.subjectKhmer,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      teachingHoursPerWeek: teachingHoursPerWeek ?? this.teachingHoursPerWeek,
      status: status,
      avatarUrl: avatarUrl,
    );
  }
}
