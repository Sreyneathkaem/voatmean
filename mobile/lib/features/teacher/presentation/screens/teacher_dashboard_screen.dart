import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import 'package:voatmean_mobile/features/teacher/data/services/teacher_service.dart';
import 'attendance_marking_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final TeacherService _teacherService = TeacherService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _slots = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    final slots = await _teacherService.getMySlots();
    if (mounted) {
      setState(() {
        _slots = slots;
        _isLoading = false;
      });
    }
  }

  String _formatKhmerDate(DateTime dt) {
    const khmerMonths = [
      'មករា', 'កុម្ភៈ', 'មីនា', 'មេសា', 'ឧសភា', 'មិថុនា',
      'កក្កដា', 'សីហា', 'កញ្ញា', 'តុលា', 'វិច្ឆិកា', 'ធ្នូ'
    ];
    const khmerDays = [
      'ចន្ទ', 'អង្គារ', 'ពុធ', 'ព្រហស្បតិ៍', 'សុក្រ', 'សៅរ៍', 'អាទិត្យ'
    ];
    final dayName = khmerDays[dt.weekday - 1];
    final monthName = khmerMonths[dt.month - 1];
    return 'ថ្ងៃ$dayName ទី${dt.day} $monthName ${dt.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      helpText: 'ជ្រើសរើសកាលបរិច្ឆេទបង្រៀន',
      cancelText: 'បោះបង់',
      confirmText: 'យល់ព្រម',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadSlots();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'បានជ្រើសរើសកាលបរិច្ឆេទ៖ ${_formatKhmerDate(_selectedDate)}',
              style: AppTypography.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('កាលវិភាគបង្រៀន', style: AppTypography.titleMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            tooltip: 'ផ្ទុកឡើងវិញ',
            onPressed: () async {
              await _loadSlots();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'បានផ្ទុកកាលវិភាគបង្រៀនឡើងវិញជោគជ័យ',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            icon: const Icon(LucideIcons.refreshCw, size: 18),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSlots,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Card with Working Date Picker
              _buildWelcomeCard(),
              const SizedBox(height: 20),

              // 2. Today's Classes Header
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
                      Text('ថ្នាក់រៀនថ្ងៃនេះ', style: AppTypography.titleMedium),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: Text(
                      _slots.isNotEmpty ? '${_slots.length} ថ្នាក់' : '២ ថ្នាក់',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Class Cards
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_slots.isNotEmpty)
                ..._slots.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildClassCard(
                        context,
                        slotId: s['slot_id']?.toString() ?? '1',
                        grade: s['class_name'] ?? 'Grade 10A',
                        gradeKhmer: s['class_name_khmer'] ?? s['class_name'] ?? 'ថ្នាក់ ១០ ក',
                        subject: s['subject_name'] ?? 'Mathematics',
                        time: s['time_slot'] ?? '08:00 - 09:30 AM',
                        room: s['room_number'] ?? 'បន្ទប់ 302',
                        studentCount: s['student_count'] is int ? s['student_count'] : 36,
                        isCompleted: s['is_marked'] == true,
                      ),
                    ))
              else ...[
                // Default demonstration classes
                _buildClassCard(
                  context,
                  slotId: '1',
                  grade: 'Grade 10A',
                  gradeKhmer: 'ថ្នាក់ ១០ ក',
                  subject: 'គណិតវិទ្យា (Mathematics)',
                  time: '08:00 - 09:30 AM',
                  room: 'បន្ទប់ 302',
                  studentCount: 36,
                  isCompleted: false,
                ),
                const SizedBox(height: 12),
                _buildClassCard(
                  context,
                  slotId: '2',
                  grade: 'Grade 12A',
                  gradeKhmer: 'ថ្នាក់ ១២ ក',
                  subject: 'គណិតវិទ្យាជាន់ខ្ពស់ (Adv. Math)',
                  time: '10:00 - 11:30 AM',
                  room: 'បន្ទប់ 501',
                  studentCount: 40,
                  isCompleted: true,
                ),
              ],
              const SizedBox(height: 20),

              // 4. Other Classes Section
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ថ្នាក់រៀនផ្សេងទៀតក្នុងសប្តាហ៍',
                    style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSimpleClassTile(
                grade: 'Grade 11B',
                gradeKhmer: 'ថ្នាក់ ១១ ខ',
                subject: 'គណិតវិទ្យា (Mathematics)',
                schedule: 'ចន្ទ, ពុធ, សុក្រ',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendar, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          _formatKhmerDate(_selectedDate),
                          style: AppTypography.font(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.chevronDown, size: 13, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'សួស្តី, លោកគ្រូ!',
                  style: AppTypography.displayMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'សូមពិនិត្យកាលវិភាគ និងស្រង់វត្តមានសិស្សសម្រាប់ថ្ងៃនេះ',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Icon(LucideIcons.calendarCheck2, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String slotId,
    required String grade,
    required String gradeKhmer,
    required String subject,
    required String time,
    required String room,
    required int studentCount,
    bool isCompleted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted ? AppColors.border : AppColors.primaryBorder,
          width: 1.2,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceMarkingScreen(
                  slotId: slotId,
                  grade: grade,
                  subject: subject,
                ),
              ),
            );
            _loadSlots();
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isCompleted ? AppColors.success : AppColors.warning,
                  width: 5,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Header & Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(grade, style: AppTypography.titleMedium),
                              const SizedBox(width: 8),
                              Text(
                                gradeKhmer,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subject,
                            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.successBg : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCompleted ? AppColors.successBorder : AppColors.warningBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted ? LucideIcons.checkCircle2 : LucideIcons.clock,
                            size: 13,
                            color: isCompleted ? AppColors.successText : AppColors.warningText,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isCompleted ? 'បានស្រង់រួច' : 'មិនទាន់ស្រង់',
                            style: AppTypography.captionBold.copyWith(
                              color: isCompleted ? AppColors.successText : AppColors.warningText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Metadata Grid (Time, Room, Students)
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(LucideIcons.clock, time, iconColor: AppColors.primary),
                    ),
                    Expanded(
                      child: _buildInfoItem(LucideIcons.mapPin, room, iconColor: const Color(0xFF0284C7)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        LucideIcons.users,
                        '$studentCount នាក់ (សិស្សសរុប)',
                        iconColor: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceMarkingScreen(
                            slotId: slotId,
                            grade: grade,
                            subject: subject,
                          ),
                        ),
                      );
                      _loadSlots();
                    },
                    icon: Icon(
                      isCompleted ? LucideIcons.eye : LucideIcons.clipboardCheck,
                      size: 16,
                    ),
                    label: Text(
                      isCompleted ? 'មើលវត្តមានឡើងវិញ' : 'ស្រង់វត្តមានសិស្ស',
                      style: AppTypography.labelMedium.copyWith(
                        color: isCompleted ? AppColors.textPrimary : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? const Color(0xFFF8FAFC) : AppColors.primary,
                      foregroundColor: isCompleted ? AppColors.textPrimary : Colors.white,
                      elevation: isCompleted ? 0 : 2,
                      side: BorderSide(
                        color: isCompleted ? AppColors.border : AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: iconColor ?? AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleClassTile({
    required String grade,
    required String gradeKhmer,
    required String subject,
    required String schedule,
  }) {
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
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceMarkingScreen(
                  slotId: '3',
                  grade: grade,
                  subject: subject,
                ),
              ),
            );
            _loadSlots();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(grade, style: AppTypography.titleSmall),
                          const SizedBox(width: 6),
                          Text(
                            gradeKhmer,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subject, style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    schedule,
                    style: AppTypography.captionBold.copyWith(color: AppColors.textSecondary),
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
  }
}
