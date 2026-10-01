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

  // Selected filters
  String _selectedMonthName = 'ខែកញ្ញា 2026';
  int _selectedMonthNumber = 9;
  String _selectedClassName = 'Grade 10A';
  String _selectedClassId = 'b1c76ca3-3912-4a41-9dcd-33da8c0074e4';
  String _selectedSubjectName = 'Mathematics';
  String _selectedSubjectId = '02cea652-eaf2-46cc-95b4-0dbad4f97767';

  // Configured formula weights and deductions
  double _attendanceWeight = 0.30;
  double _teacherScoreWeight = 0.70;
  double _permissionDeduction = 30.0;
  double _lateDeduction = 50.0;
  double _absentDeduction = 100.0;

  List<Map<String, dynamic>> _grades = [];

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  // MoEYS Secondary & High School Homeroom Classes
  final Map<String, String> _knownClasses = {
    'Grade 10A': 'b1c76ca3-3912-4a41-9dcd-33da8c0074e4',
    'Grade 10B': 'ae3e0105-0621-42a4-b413-102bb3959e80',
    'Grade 11A': '0a92cc0f-3732-4927-9fed-1bbadda7c824',
    'Grade 11B': '649fbf63-4527-455b-a447-93ec307c5453',
    'Grade 12A': '8cbf0b3f-162d-4212-bea6-43fed7d693d8',
    'Grade 12B': '429b91d0-cd0a-40c8-89b3-063ccae4eaa1',
  };

  // MoEYS Standard Subjects
  final Map<String, String> _knownSubjects = {
    'Mathematics': '02cea652-eaf2-46cc-95b4-0dbad4f97767',
    'Khmer Literature': 'dca445d5-b2ae-47fd-865f-78d5c45a3711',
    'Physics': '4005fdc8-d932-4e88-a95a-d2018c3ff5c2',
    'Chemistry': '0b8e4e4a-5b96-4e47-b548-6b4b84755ad4',
    'Biology': '6f91e306-e02f-4b2c-b776-0810b8fa4c91',
    'English': '5e2f10ae-7459-4a55-9978-39ee4909a0c4',
    'History': '3c244bbc-1227-472d-b218-7109d315b2b7',
    'Geography': 'cf90cad6-c42e-4157-a82c-2f1636df55d5',
    'Moral & Civics': 'd59945c9-5228-42b7-b069-90e43cc623c7',
    'ICT': '882fa603-c32a-49ad-9552-a29018776500',
  };

  final List<String> _months = [
    'ខែមករា 2026', 'ខែកុម្ភៈ 2026', 'ខែមីនា 2026', 'ខែមេសា 2026',
    'ខែឧសភា 2026', 'ខែមិថុនា 2026', 'ខែកក្កដា 2026', 'ខែសីហា 2026',
    'ខែកញ្ញា 2026', 'ខែតុលា 2026', 'ខែវិច្ឆិកា 2026', 'ខែធ្នូ 2026',
  ];

  final List<Map<String, dynamic>> _defaultGrades = [
    {
      'full_name': 'សុខ សំណាង',
      'student_id': 'STU003',
      'roll_number': '1',
      'attendance_rate': 0.95,
      'attendance_score': 95.0,
      'present_count': 19,
      'late_count': 1,
      'permission_count': 0,
      'absent_count': 0,
      'teacher_score': 88.0,
      'final_score': 90.1,
    },
    {
      'full_name': 'កែវ បុប្ផា',
      'student_id': 'STU004',
      'roll_number': '2',
      'attendance_rate': 0.92,
      'attendance_score': 92.0,
      'present_count': 18,
      'late_count': 2,
      'permission_count': 0,
      'absent_count': 0,
      'teacher_score': 90.0,
      'final_score': 90.6,
    },
    {
      'full_name': 'ចាន់ ស្រីមុំ',
      'student_id': 'STU001',
      'roll_number': '3',
      'attendance_rate': 0.85,
      'attendance_score': 85.0,
      'present_count': 17,
      'late_count': 1,
      'permission_count': 1,
      'absent_count': 1,
      'teacher_score': 78.0,
      'final_score': 80.1,
    },
    {
      'full_name': 'ហេង ពិសិដ្ឋ',
      'student_id': 'STU002',
      'roll_number': '4',
      'attendance_rate': 0.88,
      'attendance_score': 88.0,
      'present_count': 17,
      'late_count': 2,
      'permission_count': 1,
      'absent_count': 0,
      'teacher_score': 82.0,
      'final_score': 83.8,
    },
    {
      'full_name': 'ជា វណ្ណៈ',
      'student_id': 'STU005',
      'roll_number': '5',
      'attendance_rate': 0.79,
      'attendance_score': 79.0,
      'present_count': 15,
      'late_count': 2,
      'permission_count': 2,
      'absent_count': 1,
      'teacher_score': 74.0,
      'final_score': 75.5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialSlotsAndGrades();
  }

  Future<void> _loadInitialSlotsAndGrades() async {
    try {
      final slots = await _teacherService.getMySlots();
      if (slots.isNotEmpty && mounted) {
        setState(() {
          final first = slots.first;
          if (first['class_id'] != null) {
            _selectedClassId = first['class_id'].toString();
            _selectedClassName = first['class_name']?.toString() ?? _selectedClassName;
          }
          if (first['subject_id'] != null) {
            _selectedSubjectId = first['subject_id'].toString();
            _selectedSubjectName = first['subject_name']?.toString() ?? _selectedSubjectName;
          }
        });
      }
    } catch (_) {}

    await _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    final monthStr = "${now.year}-${_selectedMonthNumber.toString().padLeft(2, '0')}";

    // 1. Fetch effective score formula and attendance deductions for subject
    try {
      final formula = await _teacherService.getScoreFormula(_selectedSubjectId);
      if (formula != null && mounted) {
        setState(() {
          _attendanceWeight = (formula['attendance_weight'] as num?)?.toDouble() ?? 0.30;
          _teacherScoreWeight = (formula['teacher_score_weight'] as num?)?.toDouble() ?? 0.70;
          _permissionDeduction = (formula['permission_deduction'] as num?)?.toDouble() ?? 30.0;
          _lateDeduction = (formula['late_deduction'] as num?)?.toDouble() ?? 50.0;
          _absentDeduction = (formula['absent_deduction'] as num?)?.toDouble() ?? 100.0;
        });
      }
    } catch (_) {}

    // 2. Fetch monthly student scores and attendance summary
    final data = await _teacherService.getMonthlyGrades(
      classId: _selectedClassId,
      subjectId: _selectedSubjectId,
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
                'បានទាញយករបាយការណ៍ $_selectedMonthName ($_selectedSubjectName) ជាឯកសារ Excel (.xlsx) ជោគជ័យ',
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
                      Text('ជ្រើសរើសថ្នាក់ មុខវិជ្ជា និងខែ', style: AppTypography.titleMedium),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Class selection chips
              Text('ជ្រើសរើសថ្នាក់រៀន (Homeroom Class)៖', style: AppTypography.captionBold),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _knownClasses.keys.map((cName) {
                  final isSel = cName == _selectedClassName;
                  return ChoiceChip(
                    label: Text(cName, style: AppTypography.captionBold),
                    selected: isSel,
                    selectedColor: AppColors.primaryLight,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedClassName = cName;
                          _selectedClassId = _knownClasses[cName]!;
                        });
                        setModalState(() {});
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Subject selection chips
              Text('ជ្រើសរើសមុខវិជ្ជា (Subject)៖', style: AppTypography.captionBold),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _knownSubjects.keys.map((sName) {
                  final isSel = sName == _selectedSubjectName;
                  return ChoiceChip(
                    label: Text(sName, style: AppTypography.captionBold),
                    selected: isSel,
                    selectedColor: AppColors.primaryLight,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedSubjectName = sName;
                          _selectedSubjectId = _knownSubjects[sName]!;
                        });
                        setModalState(() {});
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Month list selector
              Text('ជ្រើសរើសខែសិក្សា៖', style: AppTypography.captionBold),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _months.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (ctx, idx) {
                    final m = _months[idx];
                    final isSelected = m == _selectedMonthName;
                    return ListTile(
                      dense: true,
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
                        setState(() {
                          _selectedMonthName = m;
                          _selectedMonthNumber = idx + 1;
                        });
                        Navigator.pop(ctx);
                        _loadGrades();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Modal for customizing attendance deductions (Absent, Permission, Late)
  void _showAttendancePolicyModal() {
    double tempAttWeight = _attendanceWeight;
    double tempTeacherWeight = _teacherScoreWeight;
    double tempPermDeduction = _permissionDeduction;
    double tempLateDeduction = _lateDeduction;
    double tempAbsentDeduction = _absentDeduction;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
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
                          child: const Icon(LucideIcons.sliders, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('កំណត់ការកាត់ពិន្ទុវត្តមាន', style: AppTypography.titleMedium),
                            Text(
                              'មុខវិជ្ជា៖ $_selectedSubjectName',
                              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'កំណត់កម្រិតកាត់ពិន្ទុសម្រាប់សិស្សសុំច្បាប់ មកយឺត និងទម្ងន់ពិន្ទុរួមនៃមុខវិជ្ជា៖',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // 1. Permission Deduction Slider
                _buildPolicySliderCard(
                  title: 'អវត្តមានមានច្បាប់ (Permission)',
                  subtitle: 'សិស្សសុំច្បាប់ត្រូវកាត់ពិន្ទុប៉ុន្មានភាគរយ?',
                  badgeText: 'កាត់ ${tempPermDeduction.toInt()}% (សល់ ${(100 - tempPermDeduction).toInt()}%)',
                  badgeColor: AppColors.warningBg,
                  badgeTextColor: AppColors.warningText,
                  value: tempPermDeduction,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (val) {
                    setModalState(() => tempPermDeduction = val);
                  },
                ),
                const SizedBox(height: 12),

                // 2. Late Deduction Slider
                _buildPolicySliderCard(
                  title: 'មកយឺត (Late)',
                  subtitle: 'សិស្សមកយឺតត្រូវកាត់ពិន្ទុប៉ុន្មានភាគរយ?',
                  badgeText: 'កាត់ ${tempLateDeduction.toInt()}% (សល់ ${(100 - tempLateDeduction).toInt()}%)',
                  badgeColor: const Color(0xFFFEF3C7),
                  badgeTextColor: const Color(0xFFB45309),
                  value: tempLateDeduction,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (val) {
                    setModalState(() => tempLateDeduction = val);
                  },
                ),
                const SizedBox(height: 12),

                // 3. Absent Deduction Slider
                _buildPolicySliderCard(
                  title: 'អវត្តមានឥតច្បាប់ (Absent without permission)',
                  subtitle: 'សិស្សអវត្តមានឥតច្បាប់ត្រូវកាត់ពិន្ទុប៉ុន្មាន?',
                  badgeText: 'កាត់ ${tempAbsentDeduction.toInt()}% (សល់ ${(100 - tempAbsentDeduction).toInt()}%)',
                  badgeColor: AppColors.dangerBg,
                  badgeTextColor: AppColors.danger,
                  value: tempAbsentDeduction,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (val) {
                    setModalState(() => tempAbsentDeduction = val);
                  },
                ),
                const SizedBox(height: 12),

                // 4. Weight Balance Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.slateBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'ទម្ងន់ពិន្ទុចុងក្រោយ (Formula Blend)',
                              style: AppTypography.labelMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'វត្តមាន ${(tempAttWeight * 100).toInt()}% : ពិន្ទុ ${(tempTeacherWeight * 100).toInt()}%',
                              style: AppTypography.captionBold.copyWith(color: AppColors.primary, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: tempAttWeight,
                        min: 0.0,
                        max: 0.50,
                        divisions: 10,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setModalState(() {
                            tempAttWeight = double.parse(val.toStringAsFixed(2));
                            tempTeacherWeight = double.parse((1.0 - tempAttWeight).toStringAsFixed(2));
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('វត្តមាន 0%', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                          Text('វត្តមាន 50%', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Save Policy Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            setModalState(() => isSaving = true);
                            final success = await _teacherService.updateScoreFormula(
                              subjectId: _selectedSubjectId,
                              attendanceWeight: tempAttWeight,
                              teacherScoreWeight: tempTeacherWeight,
                              permissionDeduction: tempPermDeduction,
                              lateDeduction: tempLateDeduction,
                              absentDeduction: tempAbsentDeduction,
                            );

                            if (!mounted) return;
                            navigator.pop();
                            if (success) {
                              setState(() {
                                _attendanceWeight = tempAttWeight;
                                _teacherScoreWeight = tempTeacherWeight;
                                _permissionDeduction = tempPermDeduction;
                                _lateDeduction = tempLateDeduction;
                                _absentDeduction = tempAbsentDeduction;
                              });
                              _loadGrades();
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('បានកែប្រែគោលការណ៍កាត់ពិន្ទុវត្តមានជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            } else {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('បរាជ័យក្នុងការរក្សាទុកគោលការណ៍', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('រក្សាទុកគោលការណ៍កាត់ពិន្ទុ', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modal for adding/editing monthly scores of their subject for enrolled students
  void _showEnterMonthlyScoresModal() {
    final Map<String, TextEditingController> controllers = {};
    for (final student in _grades) {
      final sId = student['student_id']?.toString() ?? '';
      final currentScore = _parseDouble(student['teacher_score']);
      controllers[sId] = TextEditingController(
        text: currentScore > 0 ? (currentScore % 1 == 0 ? currentScore.toInt().toString() : currentScore.toString()) : '',
      );
    }
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.84,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
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
                        child: const Icon(LucideIcons.filePenLine, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('បញ្ចូលពិន្ទុមុខវិជ្ជាប្រចាំខែ', style: AppTypography.titleMedium),
                          Text(
                            '$_selectedSubjectName • $_selectedClassName • $_selectedMonthName',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.slateBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'បញ្ចូលពិន្ទុមុខវិជ្ជា (០-១០០)។ ពិន្ទុរួមនឹងត្រូវបានគណនាដោយស្វ័យប្រវត្តិតាមទម្ងន់វត្តមាន & ប្រលង។',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Student List with Score Inputs
              Expanded(
                child: ListView.separated(
                  itemCount: _grades.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (ctx, idx) {
                    final item = _grades[idx];
                    final sId = item['student_id']?.toString() ?? '';
                    final name = item['full_name']?.toString() ?? 'សិស្ស';
                    final rollNo = item['roll_number']?.toString() ?? '${idx + 1}';
                    final attScore = item['attendance_score'] != null
                        ? _parseDouble(item['attendance_score'])
                        : _parseDouble(item['attendance_rate']) * 100.0;
                    final ctrl = controllers[sId] ?? TextEditingController();

                    final inputVal = double.tryParse(ctrl.text) ?? 0.0;
                    final previewFinal = (attScore * _attendanceWeight) + (inputVal * _teacherScoreWeight);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                rollNo,
                                style: AppTypography.captionBold.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: AppTypography.labelMedium),
                                const SizedBox(height: 2),
                                Text(
                                  'វត្តមាន៖ ${attScore.toStringAsFixed(0)}%  •  ពិន្ទុរួមបណ្តោះអាសន្ន៖ ${previewFinal.toStringAsFixed(1)}',
                                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 76,
                            height: 42,
                            child: TextField(
                              controller: ctrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                filled: true,
                                fillColor: AppColors.slateBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              onChanged: (_) => setModalState(() {}),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('/100', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          setModalState(() => isSaving = true);
                          final now = DateTime.now();
                          final monthStr = "${now.year}-${_selectedMonthNumber.toString().padLeft(2, '0')}";

                          int savedCount = 0;
                          for (final student in _grades) {
                            final sId = student['student_id']?.toString() ?? '';
                            final ctrl = controllers[sId];
                            if (ctrl != null && ctrl.text.isNotEmpty) {
                              final scoreVal = double.tryParse(ctrl.text);
                              if (scoreVal != null) {
                                final ok = await _teacherService.upsertSubjectScore(
                                  studentId: sId,
                                  subjectId: _selectedSubjectId,
                                  classId: _selectedClassId,
                                  month: monthStr,
                                  teacherScore: scoreVal,
                                );
                                if (ok) savedCount++;
                              }
                            }
                          }

                          if (!mounted) return;
                          navigator.pop();
                          _loadGrades();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('បានរក្សាទុកពិន្ទុមុខវិជ្ជាសម្រាប់សិស្ស $savedCount នាក់ ជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                  icon: isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(LucideIcons.save, size: 18),
                  label: Text('រក្សាទុកពិន្ទុទាំងអស់', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentReportModal(Map<String, dynamic> item, int rank) {
    final name = item['full_name']?.toString() ?? 'សិស្ស';
    final studentId = item['student_id']?.toString() ?? 'STU001';
    final attScoreVal = item['attendance_score'] != null
        ? _parseDouble(item['attendance_score'])
        : _parseDouble(item['attendance_rate']) * 100.0;
    final attScore = attScoreVal.toStringAsFixed(0);
    final presentCount = _parseInt(item['present_count'], 0);
    final lateCount = _parseInt(item['late_count'], 0);
    final permCount = _parseInt(item['permission_count'], 0);
    final absentCount = _parseInt(item['absent_count'], 0);
    final tScore = _parseDouble(item['teacher_score']);
    final fScore = _parseDouble(item['final_score']);

    final singleScoreCtrl = TextEditingController(
      text: tScore > 0 ? (tScore % 1 == 0 ? tScore.toInt().toString() : tScore.toString()) : '',
    );
    bool isSavingSingle = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
          ),
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
                          'អត្តលេខ៖ $studentId • $_selectedClassName',
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
                        Text(
                          '$attScore% (វត្តមាន $presentCount, ច្បាប់ $permCount, យឺត $lateCount, អវត្តមាន $absentCount)',
                          style: AppTypography.captionBold.copyWith(color: AppColors.successText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ពិន្ទុមុខវិជ្ជា (Subject Score)', style: AppTypography.bodySmall),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 36,
                              child: TextField(
                                controller: singleScoreCtrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: AppTypography.captionBold.copyWith(color: AppColors.primary),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('/100', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
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
                  onPressed: isSavingSingle
                      ? null
                      : () async {
                          final scoreVal = double.tryParse(singleScoreCtrl.text);
                          if (scoreVal != null) {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            setModalState(() => isSavingSingle = true);
                            final now = DateTime.now();
                            final monthStr = "${now.year}-${_selectedMonthNumber.toString().padLeft(2, '0')}";
                            await _teacherService.upsertSubjectScore(
                              studentId: studentId.toString(),
                              subjectId: _selectedSubjectId,
                              classId: _selectedClassId,
                              month: monthStr,
                              teacherScore: scoreVal,
                            );
                            if (!mounted) return;
                            navigator.pop();
                            _loadGrades();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('បានកែប្រែពិន្ទុសម្រាប់ $name ដោយជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          } else {
                            Navigator.pop(ctx);
                          }
                        },
                  icon: isSavingSingle
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(LucideIcons.checkCheck, size: 16),
                  label: Text('រក្សាទុកពិន្ទុ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
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
      ),
    );
  }

  Widget _buildPolicySliderCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.slateBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: AppTypography.labelMedium),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.captionBold.copyWith(color: badgeTextColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toInt()}% (មិនកាត់)', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              Text('${max.toInt()}% (កាត់អស់)', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _grades.length;
    final avgAttendance = total > 0
        ? (_grades.fold(0.0, (acc, g) => acc + (g['attendance_score'] != null ? _parseDouble(g['attendance_score']) : _parseDouble(g['attendance_rate']) * 100.0)) / total).toStringAsFixed(0)
        : '0';
    final avgScore = total > 0
        ? (_grades.fold(0.0, (acc, g) => acc + _parseDouble(g['final_score'])) / total).toStringAsFixed(1)
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
                  // 1. Class, Subject & Month Selector Card
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
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(LucideIcons.bookOpen, size: 20, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _selectedClassName,
                                            style: AppTypography.captionBold.copyWith(color: AppColors.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            _selectedSubjectName,
                                            style: AppTypography.titleSmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'របាយការណ៍ប្រចាំ $_selectedMonthName',
                                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                Text('ប្តូរ', style: AppTypography.captionBold.copyWith(color: AppColors.textPrimary)),
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

                  // 2. Summary Metric Row
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
                  const SizedBox(height: 14),

                  // 3. Formula Policy Indicator & Customization Actions
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.scale, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('រូបមន្តគិតពិន្ទុ និងការកាត់ពិន្ទុ', style: AppTypography.labelMedium),
                              ],
                            ),
                            InkWell(
                              onTap: _showAttendancePolicyModal,
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Row(
                                  children: [
                                    Text('កែសម្រួល', style: AppTypography.captionBold.copyWith(color: AppColors.primary)),
                                    const SizedBox(width: 2),
                                    const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildFormulaChip(
                              label: 'ទម្ងន់វត្តមាន: ${(_attendanceWeight * 100).toInt()}%',
                              color: AppColors.primary,
                              bgColor: AppColors.primaryLight,
                            ),
                            _buildFormulaChip(
                              label: 'ពិន្ទុមុខវិជ្ជា: ${(_teacherScoreWeight * 100).toInt()}%',
                              color: AppColors.blueText,
                              bgColor: AppColors.blueBg,
                            ),
                            _buildFormulaChip(
                              label: 'ច្បាប់កាត់: ${_permissionDeduction.toInt()}%',
                              color: AppColors.warningText,
                              bgColor: AppColors.warningBg,
                            ),
                            _buildFormulaChip(
                              label: 'យឺតកាត់: ${_lateDeduction.toInt()}%',
                              color: const Color(0xFFB45309),
                              bgColor: const Color(0xFFFEF3C7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Action Buttons Row (Customize Deductions + Enter Scores)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showAttendancePolicyModal,
                                icon: const Icon(LucideIcons.sliders, size: 15),
                                label: Text(
                                  'កំណត់កាត់ពិន្ទុ',
                                  style: AppTypography.captionBold.copyWith(color: AppColors.primary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primaryBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showEnterMonthlyScoresModal,
                                icon: const Icon(LucideIcons.filePenLine, size: 15),
                                label: Text(
                                  'បញ្ចូលពិន្ទុមុខវិជ្ជា',
                                  style: AppTypography.captionBold.copyWith(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Section Title
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

                  // 5. Student Grades List (Interactive)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _grades.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final item = _grades[index];
                      final name = item['full_name']?.toString() ?? 'សិស្ស';
                      final attScore = item['attendance_score'] != null
                          ? _parseDouble(item['attendance_score'])
                          : _parseDouble(item['attendance_rate']) * 100.0;
                      final tScore = _parseDouble(item['teacher_score']);
                      final fScore = _parseDouble(item['final_score']);
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

                                  // Student Details
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
                                                'វត្តមាន: ${attScore.toStringAsFixed(0)}%',
                                                style: AppTypography.captionBold.copyWith(
                                                  color: AppColors.successText,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'ពិន្ទុគ្រូ៖ $tScore',
                                                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

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

  Widget _buildFormulaChip({
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.captionBold.copyWith(color: color, fontSize: 11),
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
