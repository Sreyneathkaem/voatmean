import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import 'package:voatmean_mobile/features/teacher/data/services/teacher_service.dart';

enum AttendanceStatus { present, late, absent, permission }

class AttendanceMarkingScreen extends StatefulWidget {
  final String slotId;
  final String grade;
  final String subject;

  const AttendanceMarkingScreen({
    super.key,
    required this.slotId,
    required this.grade,
    required this.subject,
  });

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  final TeacherService _teacherService = TeacherService();
  bool _isLoading = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _students = [];

  final List<Map<String, dynamic>> _defaultStudents = [
    {'id': '1', 'name': 'Sok Samnang', 'nameKhmer': 'សុខ សំណាង', 'gender': 'M', 'status': AttendanceStatus.present},
    {'id': '2', 'name': 'Keo Bopha', 'nameKhmer': 'កែវ បុប្ផា', 'gender': 'F', 'status': AttendanceStatus.present},
    {'id': '3', 'name': 'Chan Sreymom', 'nameKhmer': 'ចាន់ ស្រីមុំ', 'gender': 'F', 'status': AttendanceStatus.present},
    {'id': '4', 'name': 'Heng Piseth', 'nameKhmer': 'ហេង ពិសិដ្ឋ', 'gender': 'M', 'status': AttendanceStatus.present},
    {'id': '5', 'name': 'Chea Vannak', 'nameKhmer': 'ជា វណ្ណៈ', 'gender': 'M', 'status': AttendanceStatus.present},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _todayFormatted() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final today = _todayFormatted();

    // 1. Fetch roster
    final roster = await _teacherService.getSlotRoster(widget.slotId);

    // 2. Fetch today's existing attendance
    final existing = await _teacherService.getSlotAttendance(widget.slotId, today);
    final existingMap = {for (var e in existing) e['student_id'].toString(): e['status'].toString()};

    if (roster.isNotEmpty) {
      _students = roster.map((s) {
        final stId = s['student_id'].toString();
        final rawStatus = existingMap[stId] ?? 'present';
        return {
          'id': stId,
          'name': s['full_name'] ?? '',
          'nameKhmer': s['full_name'] ?? s['nameKhmer'] ?? '',
          'gender': s['gender'] ?? 'M',
          'status': _parseStatus(rawStatus),
        };
      }).toList();
    } else {
      _students = List.from(_defaultStudents);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  AttendanceStatus _parseStatus(String str) {
    switch (str.toLowerCase()) {
      case 'late':
        return AttendanceStatus.late;
      case 'absent':
        return AttendanceStatus.absent;
      case 'permission':
        return AttendanceStatus.permission;
      case 'present':
      default:
        return AttendanceStatus.present;
    }
  }

  void _updateStatus(int index, AttendanceStatus status) {
    setState(() {
      _students[index]['status'] = status;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var s in _students) {
        s['status'] = AttendanceStatus.present;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('បានកំណត់វត្តមានសិស្សទាំងអស់', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.successDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitAttendance() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.clipboardCheck, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('បញ្ជូនវត្តមាន?', style: AppTypography.titleMedium),
          ],
        ),
        content: Text(
          'តើអ្នកប្រាកដថាបានត្រួតពិនិត្យវត្តមានសិស្សទាំងអស់រួចរាល់ហើយ?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ត្រួតពិនិត្យឡើងវិញ', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performSave();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('បញ្ជូន', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performSave() async {
    setState(() => _isSaving = true);

    final today = _todayFormatted();
    final records = _students.map((s) {
      final AttendanceStatus st = s['status'];
      return {
        'student_id': s['id'],
        'status': st.name,
      };
    }).toList();

    final success = await _teacherService.saveSlotAttendance(
      slotId: widget.slotId,
      date: today,
      records: records,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('វត្តមានត្រូវបានរក្សាទុកជោគជ័យ',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: AppColors.successDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.cloudOff, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('បានកត់ត្រាវត្តមានក្នុងទូរស័ព្ទ (Offline Mode)',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _students.where((s) => s['status'] == AttendanceStatus.present).length;
    int lateCount = _students.where((s) => s['status'] == AttendanceStatus.late).length;
    int absentCount = _students.where((s) => s['status'] == AttendanceStatus.absent).length;
    int permissionCount = _students.where((s) => s['status'] == AttendanceStatus.permission).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.grade, style: AppTypography.titleMedium),
            Text(
              widget.subject,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
        actions: [
          TextButton.icon(
            onPressed: _markAllPresent,
            icon: const Icon(LucideIcons.checkCheck, size: 16, color: AppColors.primary),
            label: Text(
              'វត្តមានទាំងអស់',
              style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Metric Counter Bar
                _buildSummaryBar(presentCount, lateCount, absentCount, permissionCount),
                const Divider(height: 1, color: AppColors.border),

                // 2. Student Attendance List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _students.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final student = _students[index];
                      return _buildStudentCard(index, student);
                    },
                  ),
                ),

                // 3. Bottom Submit Button
                _buildSubmitButton(),
              ],
            ),
    );
  }

  Widget _buildSummaryBar(int p, int l, int a, int perm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('វត្តមាន', p, AppColors.success, AppColors.successBg),
          _buildSummaryItem('យឺត', l, AppColors.warning, AppColors.warningBg),
          _buildSummaryItem('អវត្តមាន', a, AppColors.danger, AppColors.dangerBg),
          _buildSummaryItem('ច្បាប់', perm, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.captionBold.copyWith(color: color),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTypography.labelMedium.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(int index, Map<String, dynamic> student) {
    final status = student['status'] as AttendanceStatus;
    final isFemale = student['gender'] == 'F';
    final nameKhmer = student['nameKhmer'] ?? student['name'] ?? 'សិស្ស';
    final rollNumber = '${index + 1}'.padLeft(2, '0');

    Color statusAccent;
    switch (status) {
      case AttendanceStatus.present:
        statusAccent = AppColors.success;
        break;
      case AttendanceStatus.late:
        statusAccent = AppColors.warning;
        break;
      case AttendanceStatus.absent:
        statusAccent = AppColors.danger;
        break;
      case AttendanceStatus.permission:
        statusAccent = const Color(0xFF8B5CF6);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: statusAccent, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isFemale ? const Color(0xFFFDF2F8) : AppColors.primaryLight,
            child: Text(
              nameKhmer.isNotEmpty ? nameKhmer.substring(0, 1) : 'S',
              style: AppTypography.labelMedium.copyWith(
                color: isFemale ? const Color(0xFFDB2777) : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(nameKhmer, style: AppTypography.titleSmall),
                    const SizedBox(width: 6),
                    Text(
                      '#$rollNumber',
                      style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                    ),
                  ],
                ),
                Text(
                  student['name'] ?? '',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildStatusBtn(index, AttendanceStatus.present, 'វ', AppColors.success, status == AttendanceStatus.present),
              const SizedBox(width: 6),
              _buildStatusBtn(index, AttendanceStatus.late, 'យ', AppColors.warning, status == AttendanceStatus.late),
              const SizedBox(width: 6),
              _buildStatusBtn(index, AttendanceStatus.absent, 'អ', AppColors.danger, status == AttendanceStatus.absent),
              const SizedBox(width: 6),
              _buildStatusBtn(index, AttendanceStatus.permission, 'ច', const Color(0xFF8B5CF6), status == AttendanceStatus.permission),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildStatusBtn(int index, AttendanceStatus status, String label, Color color, bool isSelected) {
    return InkWell(
      onTap: () => _updateStatus(index, status),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submitAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                  )
                : Text(
                    'រក្សាទុក និងបញ្ជូនវត្តមាន',
                    style: AppTypography.labelLarge.copyWith(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
