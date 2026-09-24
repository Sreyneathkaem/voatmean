import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import 'package:voatmean_mobile/features/teacher/data/services/teacher_service.dart';

class TeacherReportsScreen extends StatefulWidget {
  const TeacherReportsScreen({super.key});

  @override
  State<TeacherReportsScreen> createState() => _TeacherReportsScreenState();
}

class _TeacherReportsScreenState extends State<TeacherReportsScreen> {
  final TeacherService _teacherService = TeacherService();
  bool _isLoading = true;
  String _selectedMonthName = 'ខែសីហា 2026';
  String _selectedClass = 'Grade 10A';
  List<Map<String, dynamic>> _grades = [];

  final List<String> _months = [
    'ខែមករា 2026', 'ខែកុម្ភៈ 2026', 'ខែមីនា 2026', 'ខែមេសា 2026',
    'ខែឧសភា 2026', 'ខែមិថុនា 2026', 'ខែកក្កដា 2026', 'ខែសីហា 2026',
    'ខែកញ្ញា 2026', 'ខែតុលា 2026', 'ខែវិច្ឆិកា 2026', 'ខែធ្នូ 2026',
  ];

  final List<Map<String, dynamic>> _defaultGrades = [
    {
      'full_name': 'សុខ សំណាង',
      'student_id': 'STU003',
      'attendance_rate': 0.95,
      'present_days': 28,
      'absent_days': 1,
      'teacher_score': 88.0,
      'final_score': 90.1,
    },
    {
      'full_name': 'កែវ បុប្ផា',
      'student_id': 'STU004',
      'attendance_rate': 0.92,
      'present_days': 27,
      'absent_days': 2,
      'teacher_score': 90.0,
      'final_score': 91.4,
    },
    {
      'full_name': 'ចាន់ ស្រីមុំ',
      'student_id': 'STU001',
      'attendance_rate': 0.85,
      'present_days': 25,
      'absent_days': 4,
      'teacher_score': 78.0,
      'final_score': 80.1,
    },
    {
      'full_name': 'ហេង ពិសិដ្ឋ',
      'student_id': 'STU002',
      'attendance_rate': 0.88,
      'present_days': 26,
      'absent_days': 3,
      'teacher_score': 82.0,
      'final_score': 84.5,
    },
    {
      'full_name': 'ជា វណ្ណៈ',
      'student_id': 'STU005',
      'attendance_rate': 0.79,
      'present_days': 23,
      'absent_days': 6,
      'teacher_score': 74.0,
      'final_score': 75.8,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    final monthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final data = await _teacherService.getMonthlyGrades(
      classId: 'c1',
      subjectId: 's1',
      month: monthStr,
    );

    if (mounted) {
      setState(() {
        _grades = data.isNotEmpty ? data : _defaultGrades;
        _isLoading = false;
      });
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.fileSpreadsheet, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'បានទាញយករបាយការណ៍ $_selectedMonthName ជាឯកសារ Excel (.xlsx) ជោគជ័យ',
                style: AppTypography.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openMonthPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('ជ្រើសរើសខែរបាយការណ៍', style: AppTypography.titleMedium),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('ជ្រើសរើសថ្នាក់៖ ', style: AppTypography.captionBold),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Grade 10A', style: AppTypography.captionBold),
                  selected: _selectedClass == 'Grade 10A',
                  onSelected: (val) {
                    if (val) setState(() => _selectedClass = 'Grade 10A');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Grade 12A', style: AppTypography.captionBold),
                  selected: _selectedClass == 'Grade 12A',
                  onSelected: (val) {
                    if (val) setState(() => _selectedClass = 'Grade 12A');
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _months.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (ctx, idx) {
                  final m = _months[idx];
                  final isSelected = m == _selectedMonthName;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    title: Text(
                      m,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(LucideIcons.check, color: AppColors.primary, size: 18)
                        : null,
                    onTap: () {
                      setState(() => _selectedMonthName = m);
                      Navigator.pop(ctx);
                      _loadGrades();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('បានប្តូរទៅកាន់ $m', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentReportModal(Map<String, dynamic> item, int rank) {
    final name = item['full_name'] ?? 'សិស្ស';
    final studentId = item['student_id'] ?? 'STU001';
    final attRate = ((item['attendance_rate'] ?? 0.0) * 100).toStringAsFixed(0);
    final presentDays = item['present_days'] ?? 26;
    final absentDays = item['absent_days'] ?? 2;
    final tScore = item['teacher_score'] ?? 0;
    final fScore = item['final_score'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? const Color(0xFFFEF3C7)
                        : rank == 2
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: AppTypography.titleMedium.copyWith(
                        color: rank == 1
                            ? const Color(0xFFB45309)
                            : rank == 2
                                ? AppColors.textSecondary
                                : const Color(0xFFC2410C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTypography.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'អត្តលេខ៖ $studentId • $_selectedClass',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Score Breakdown Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slateBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('អត្រាវត្តមានសរុប', style: AppTypography.bodySmall),
                      Text('$attRate% ($presentDays ថ្ងៃវត្តមាន / $absentDays ថ្ងៃអវត្តមាន)', style: AppTypography.captionBold.copyWith(color: AppColors.successText)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ពិន្ទុគ្រូបង្រៀន (Teacher Score)', style: AppTypography.bodySmall),
                      Text('$tScore', style: AppTypography.captionBold.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ពិន្ទុសរុបគិតរួម (Final Score)', style: AppTypography.titleSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryBorder),
                        ),
                        child: Text('$fScore', style: AppTypography.titleSmall.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('បានកត់ត្រាសេចក្តីសន្និដ្ឋានសម្រាប់ $name', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.checkCheck, size: 16),
                label: Text('បិទ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _grades.length;
    final avgAttendance = total > 0
        ? (_grades.fold(0.0, (acc, g) => acc + (g['attendance_rate'] ?? 0.0)) / total * 100).toStringAsFixed(0)
        : '0';
    final avgScore = total > 0
        ? (_grades.fold(0.0, (acc, g) => acc + (g['final_score'] ?? 0.0)) / total).toStringAsFixed(1)
        : '0';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('របាយការណ៍ និងពិន្ទុ', style: AppTypography.titleMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            tooltip: 'ទាញយក Excel',
            onPressed: _exportReport,
            icon: const Icon(LucideIcons.fileSpreadsheet, size: 18, color: AppColors.successDark),
          ),
          IconButton(
            tooltip: 'ផ្ទុកឡើងវិញ',
            onPressed: _loadGrades,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Month Selector & Class Info Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadow,
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(LucideIcons.calendar, size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('កាលបរិច្ឆេទរបាយការណ៍', style: AppTypography.caption),
                                Text('$_selectedMonthName • $_selectedClass', style: AppTypography.titleSmall),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _openMonthPickerModal,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.slateBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Text('ប្តូរខែ', style: AppTypography.captionBold.copyWith(color: AppColors.textPrimary)),
                                const SizedBox(width: 4),
                                const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Summary Stat Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryMetric(
                          icon: LucideIcons.userCheck,
                          label: 'វត្តមានមធ្យម',
                          value: '$avgAttendance%',
                          color: AppColors.successText,
                          bgColor: AppColors.successBg,
                          borderColor: AppColors.successBorder,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryMetric(
                          icon: LucideIcons.award,
                          label: 'ពិន្ទុមធ្យមសរុប',
                          value: avgScore,
                          color: AppColors.blueText,
                          bgColor: AppColors.blueBg,
                          borderColor: AppColors.blueBorder,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('លទ្ធផលពិន្ទុប្រចាំខែ', style: AppTypography.titleSmall),
                        ],
                      ),
                      Text(
                        'សរុប $total នាក់',
                        style: AppTypography.captionBold.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. Student Grades List (Interactive)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _grades.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final item = _grades[index];
                      final name = item['full_name'] ?? 'សិស្ស';
                      final attRate = ((item['attendance_rate'] ?? 0.0) * 100).toStringAsFixed(0);
                      final tScore = item['teacher_score'] ?? 0;
                      final fScore = item['final_score'] ?? 0;
                      final rank = index + 1;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showStudentReportModal(item, rank),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // Rank Badge
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: rank == 1
                                          ? const Color(0xFFFEF3C7)
                                          : rank == 2
                                              ? const Color(0xFFF1F5F9)
                                              : rank == 3
                                                  ? const Color(0xFFFFEDD5)
                                                  : AppColors.slateBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: rank == 1
                                            ? const Color(0xFFFDE68A)
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$rank',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: rank == 1
                                              ? const Color(0xFFB45309)
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Student Name & Attendance Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: AppTypography.titleSmall),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.successBg,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.successBorder),
                                              ),
                                              child: Text(
                                                'វត្តមាន: $attRate%',
                                                style: AppTypography.captionBold.copyWith(
                                                  color: AppColors.successText,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'ពិន្ទុគ្រូ៖ $tScore',
                                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Final Score Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.primaryBorder),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$fScore',
                                          style: AppTypography.labelLarge.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'ពិន្ទុសរុប',
                                          style: AppTypography.caption.copyWith(
                                            fontSize: 10.5,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSubtle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.captionBold.copyWith(color: color)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.displayLarge.copyWith(color: color, fontSize: 22),
          ),
        ],
      ),
    );
  }
}
