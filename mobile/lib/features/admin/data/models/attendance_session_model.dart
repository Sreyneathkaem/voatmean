class AttendanceStats {
  final int total;
  final int present;
  final int late;
  final int absent;

  AttendanceStats({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
  });
}

class AttendanceSession {
  final String id;
  final String className;
  final String subject;
  final String teacherName;
  final bool submitted;
  final AttendanceStats stats;

  AttendanceSession({
    required this.id,
    required this.className,
    required this.subject,
    required this.teacherName,
    required this.submitted,
    required this.stats,
  });
}
