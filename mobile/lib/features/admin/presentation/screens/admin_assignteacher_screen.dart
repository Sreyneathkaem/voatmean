import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import '../widgets/admin_modals.dart';
import '../widgets/admin_bulk_import_modal.dart';
import '../../data/models/admin_models.dart';
import '../../data/services/admin_service.dart';

class AdminAssignTeacherScreen extends StatefulWidget {
  const AdminAssignTeacherScreen({super.key});

  @override
  State<AdminAssignTeacherScreen> createState() => _AdminAssignTeacherScreenState();
}

class _AdminAssignTeacherScreenState extends State<AdminAssignTeacherScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  String _subjectFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final teachersData = await _adminService.getTeachers();
    final classesData = await _adminService.getHomeroomClasses();

    if (!mounted) return;
    setState(() {
      if (teachersData.isNotEmpty) {
        _teachers.clear();
        for (final t in teachersData) {
          final fullName = t['full_name']?.toString() ?? 'គ្រូបង្រៀន';
          final email = t['email']?.toString() ?? '';
          final isFemale = fullName.contains('Ms.') || fullName.contains('អ្នកគ្រូ');
          _teachers.add(
            TeacherModel(
              id: t['user_id']?.toString() ?? '',
              name: fullName,
              nameKhmer: fullName,
              gender: isFemale ? 'F' : 'M',
              phone: '012 345 678',
              email: email,
              subject: (t['subject_names'] as String?)?.isNotEmpty == true
                  ? t['subject_names']
                  : 'គណិតវិទ្យា',
              subjectKhmer: (t['subject_names'] as String?)?.isNotEmpty == true
                  ? t['subject_names']
                  : 'គណិតវិទ្យា',
              assignedClasses: (t['class_names'] as String?)?.isNotEmpty == true
                  ? (t['class_names'] as String).split(', ')
                  : [],
              teachingHoursPerWeek: int.tryParse('${t['teaching_hours']}') ?? 18,
              avatarUrl: isFemale
                  ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKXn-M7jF75SMdrp_hGjewG7ANg6848MJ5nrOG_44YRFPaWD40XYQEjgp4g7PfJRXS1bs-O6q0jLQZt7xim1XJrHg_A03d7vQJ-C0CgG-f-pH1Cs6A5zPbrcJQODahwb0Cbqhsz3VjyLDqSSLW43iS-rwkuYmX4ODnTPXLT6wA4a4TcGP61Ka7QtTlJNJghMNGVTpZ1RhT_w7fmn1DZOyhL_XxomSk3GnTJDWUOSZNU4hFLXeR7xc'
                  : 'https://lh3.googleusercontent.com/aida-public/AB6AXuBW60befM5ZEuh3cxe1G0lFhJPxhypregWJHKo1-hfuMx2Nz3QkzlB8NeWkXkCk5BQl_PRTXh7PPqYrIg5drnobS_azzQ1KBedpg20vJWfNGNC4vk5_7F8I7Q8bkuWLBti5jbTOUK396MJMdlrBX-yE2a87Sqt5Ki9PuayDZHI35cIW-aeXzcHeERXz1oJ_7ZxU4WqN9usU742nu8iXkUIrJV5DQJkQUN5eeqfpUh-CCPVL1daNeU',
            ),
          );
        }
      }

      if (classesData.isNotEmpty) {
        _classes.clear();
        for (final row in classesData) {
          final className = row['class_name']?.toString() ?? 'Class';
          if (className.contains('UNASSIGNED')) continue;
          _classes.add(
            ClassItem(
              id: row['class_id']?.toString() ?? '',
              grade: className,
              gradeKhmer: className.replaceAll('Grade ', 'ថ្នាក់ '),
              subject: (row['subject_names'] as String?)?.isNotEmpty == true
                  ? row['subject_names']
                  : 'ទូទៅ',
              subjectKhmer: (row['subject_names'] as String?)?.isNotEmpty == true
                  ? row['subject_names']
                  : 'ទូទៅ',
              academicYear: (row['academic_year_id']?.toString() ?? '2026-2027')
                  .replaceAll('-', '–'),
              assignedTeacherId:
                  (row['teacher_ids'] as String?)?.split(',').first.trim() ?? '',
              assignedTeacherName:
                  (row['teacher_names'] as String?)?.split(',').first.trim() ??
                      'មិនទាន់ចាត់តាំង',
              assignedTeacherKhmer:
                  (row['teacher_names'] as String?)?.split(',').first.trim() ??
                      'មិនទាន់ចាត់តាំង',
              hoursPerWeek: int.tryParse('${row['hours_per_week']}') ?? 4,
              totalStudents: int.tryParse('${row['student_count']}') ?? 0,
            ),
          );
        }
      }
    });
  }

  final List<TeacherModel> _teachers = [
    TeacherModel(
      id: '8f7bcc0f-c914-4757-9738-d7f257c4c1a2',
      name: 'Kaem Sreyneath',
      nameKhmer: 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)',
      gender: 'F',
      phone: '012 345 678',
      email: 'k.sreyneath24@gmail.com',
      subject: 'Mathematics',
      subjectKhmer: 'គណិតវិទ្យា',
      assignedClasses: ['Grade 10A', 'Grade 11A', 'Grade 12B'],
      teachingHoursPerWeek: 18,
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKXn-M7jF75SMdrp_hGjewG7ANg6848MJ5nrOG_44YRFPaWD40XYQEjgp4g7PfJRXS1bs-O6q0jLQZt7xim1XJrHg_A03d7vQJ-C0CgG-f-pH1Cs6A5zPbrcJQODahwb0Cbqhsz3VjyLDqSSLW43iS-rwkuYmX4ODnTPXLT6wA4a4TcGP61Ka7QtTlJNJghMNGVTpZ1RhT_w7fmn1DZOyhL_XxomSk3GnTJDWUOSZNU4hFLXeR7xc',
    ),
    TeacherModel(
      id: '83a60985-e10d-47ed-96d2-f888aef71a78',
      name: 'Yung Sreyneang',
      nameKhmer: 'អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)',
      gender: 'F',
      phone: '098 765 432',
      email: 'neangsrey137@gmail.com',
      subject: 'Physics',
      subjectKhmer: 'រូបវិទ្យា',
      assignedClasses: ['Grade 10B', 'Grade 11B', 'Grade 12A'],
      teachingHoursPerWeek: 16,
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKXn-M7jF75SMdrp_hGjewG7ANg6848MJ5nrOG_44YRFPaWD40XYQEjgp4g7PfJRXS1bs-O6q0jLQZt7xim1XJrHg_A03d7vQJ-C0CgG-f-pH1Cs6A5zPbrcJQODahwb0Cbqhsz3VjyLDqSSLW43iS-rwkuYmX4ODnTPXLT6wA4a4TcGP61Ka7QtTlJNJghMNGVTpZ1RhT_w7fmn1DZOyhL_XxomSk3GnTJDWUOSZNU4hFLXeR7xc',
    ),
  ];

  final List<ClassItem> _classes = [
    ClassItem(
      id: 'cls-1',
      grade: 'Grade 10A',
      gradeKhmer: 'ថ្នាក់ ១០ ក',
      subject: 'គណិតវិទ្យា',
      subjectKhmer: 'គណិតវិទ្យា',
      academicYear: '2026–2027',
      assignedTeacherId: '8f7bcc0f-c914-4757-9738-d7f257c4c1a2',
      assignedTeacherName: 'Kaem Sreyneath',
      assignedTeacherKhmer: 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)',
      hoursPerWeek: 6,
      totalStudents: 36,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeacherModel> get _filteredTeachers {
    return _teachers.where((t) {
      final matchesSubject = _subjectFilter == 'all'
          ? true
          : t.subject.toLowerCase() == _subjectFilter.toLowerCase() ||
              t.subjectKhmer.contains(_subjectFilter);

      final q = _searchQuery.toLowerCase();
      final matchesSearch = t.nameKhmer.toLowerCase().contains(q) ||
          t.name.toLowerCase().contains(q) ||
          t.phone.contains(q) ||
          t.email.toLowerCase().contains(q);

      return matchesSubject && matchesSearch;
    }).toList();
  }

  void _openAddTeacherModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTeacherBottomSheet(
        classes: _classes,
        onAdded: (newTeacher) {
          setState(() => _teachers.add(newTeacher));
        },
      ),
    );
  }

  void _openEditTeacherModal(TeacherModel teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditTeacherModal(
        teacher: teacher,
        classes: _classes,
        onUpdated: (updated) {
          setState(() {
            final idx = _teachers.indexWhere((t) => t.id == updated.id);
            if (idx != -1) _teachers[idx] = updated;
          });
        },
      ),
    );
  }

  void _confirmCallTeacher(TeacherModel teacher) {
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
              child: const Icon(LucideIcons.phoneCall, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('ទាក់ទងគ្រូបង្រៀន', style: AppTypography.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('តើលោកអ្នកចង់ហៅទូរស័ព្ទទៅកាន់ ${teacher.nameKhmer} (${teacher.name}) មែនទេ?', style: AppTypography.bodyMedium),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.slateBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.phone, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(teacher.phone, style: AppTypography.titleSmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('កំពុងហៅចេញទៅកាន់ ${teacher.phone}...', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('ហៅចេញ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteTeacher(TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('លុបគ្រូបង្រៀន?', style: AppTypography.titleMedium),
        content: Text('តើអ្នកប្រាកដថាចង់លុបលោកគ្រូ/អ្នកគ្រូ ${teacher.nameKhmer}?', style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _teachers.removeWhere((t) => t.id == teacher.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: Text('លុប', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openTeacherDetailModal(TeacherModel teacher) {
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    teacher.nameKhmer.isNotEmpty ? teacher.nameKhmer.substring(0, 1) : 'គ',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(teacher.nameKhmer, style: AppTypography.titleMedium),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              teacher.subjectKhmer,
                              style: AppTypography.captionBold.copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${teacher.name} • ${teacher.gender == 'M' ? 'ប្រុស' : 'ស្រី'}',
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
            const SizedBox(height: 18),

            // Teaching Stats Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.slateBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('${teacher.teachingHoursPerWeek} ម៉ោង', style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 2),
                      Text('បង្រៀន/សប្តាហ៍', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${teacher.assignedClasses.length} ថ្នាក់', style: AppTypography.titleMedium.copyWith(color: AppColors.successText)),
                      const SizedBox(height: 2),
                      Text('ថ្នាក់ទទួលបន្ទុក', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Assigned Classes
            Text('បញ្ជីថ្នាក់ទទួលបន្ទុក៖', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: teacher.assignedClasses.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(c, style: AppTypography.labelSmall),
                  )).toList(),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openEditTeacherModal(teacher);
                    },
                    icon: const Icon(LucideIcons.edit3, size: 16),
                    label: Text('កែប្រែ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmCallTeacher(teacher);
                    },
                    icon: const Icon(LucideIcons.phone, size: 16),
                    label: Text('ហៅទូរស័ព្ទ', style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('គ្រប់គ្រងគ្រូបង្រៀន', style: AppTypography.titleMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Top Header Banner
          _buildHeaderBanner(),
          const SizedBox(height: 14),

          // 2. Search Input
          _buildSearchBar(),
          const SizedBox(height: 14),

          // 3. Teachers List
          _buildTeachersList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.users, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'គ្រូបង្រៀនក្នុងប្រព័ន្ធ',
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'សរុបមានគ្រូបង្រៀនចំនួន ${_teachers.length} នាក់ក្នុងសាលា',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AdminBulkImportModal.show(
                    context,
                    importType: BulkImportType.teachers,
                    onImportSuccess: _loadData,
                  ),
                  icon: const Icon(LucideIcons.fileSpreadsheet, size: 14, color: Color(0xFF16A34A)),
                  label: Text(
                    'នាំចូល Sheet',
                    style: AppTypography.labelSmall.copyWith(color: const Color(0xFF16A34A), fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF86EFAC)),
                    backgroundColor: const Color(0xFFF0FDF4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openAddTeacherModal,
                  icon: const Icon(LucideIcons.userPlus, size: 14),
                  label: Text(
                    'បន្ថែមគ្រូថ្មី',
                    style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ទាំងអស់', 'all'),
                _buildFilterChip('គណិតវិទ្យា', 'Mathematics'),
                _buildFilterChip('រូបវិទ្យា', 'Physics'),
                _buildFilterChip('គីមីវិទ្យា', 'Chemistry'),
                _buildFilterChip('ភាសាអង់គ្លេស', 'English Literature'),
                _buildFilterChip('ភាសាខ្មែរ', 'Khmer Literature'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
    final isSelected = _subjectFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _subjectFilter = id),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: AppTypography.captionBold.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSubtle),
        hintText: 'ស្វែងរកតាមឈ្មោះ លេខទូរស័ព្ទ ឬអុីមែល...',
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTeachersList() {
    if (_filteredTeachers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.users, size: 40, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text(
              'មិនមានគ្រូបង្រៀនត្រូវនឹងលក្ខខណ្ឌស្វែងរកទេ',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredTeachers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final t = _filteredTeachers[index];
        return _buildTeacherCard(t);
      },
    );
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openTeacherDetailModal(teacher),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 4.5),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
        children: [
          // Row 1: Profile & Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: teacher.avatarUrl.trim().isNotEmpty
                      ? Image.network(
                          teacher.avatarUrl.trim(),
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(
                            child: Text(
                              teacher.nameKhmer.isNotEmpty ? teacher.nameKhmer.substring(0, 1) : 'គ',
                              style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            teacher.nameKhmer.isNotEmpty ? teacher.nameKhmer.substring(0, 1) : 'គ',
                            style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                          ),
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
                        Expanded(
                          child: Text(
                            teacher.nameKhmer,
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openEditTeacherModal(teacher),
                          icon: const Icon(LucideIcons.edit2, size: 16),
                          color: AppColors.textMuted,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => _deleteTeacher(teacher),
                          icon: const Icon(LucideIcons.trash2, size: 16),
                          color: AppColors.danger,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: teacher.gender == 'F' ? const Color(0xFFFDF2F8) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            teacher.gender == 'F' ? 'ស្រី' : 'ប្រុស',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: teacher.gender == 'F' ? const Color(0xFFDB2777) : const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primaryBorder),
                            ),
                            child: Text(
                              teacher.subjectKhmer,
                              style: AppTypography.captionBold.copyWith(color: AppColors.primary, fontSize: 10.5),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      teacher.email,
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Badges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.slateBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.graduationCap, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('ថ្នាក់ទទួលបន្ទុក៖', style: AppTypography.captionBold.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    Text('${teacher.teachingHoursPerWeek} ម៉ោង/សប្តាហ៍', style: AppTypography.captionBold.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                if (teacher.assignedClasses.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: teacher.assignedClasses.map((c) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(c, style: AppTypography.captionBold.copyWith(fontSize: 11)),
                        )).toList(),
                  )
                else
                  Text('មិនទាន់កំណត់ថ្នាក់', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Row 3: Contact Actions
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  LucideIcons.phone,
                  teacher.phone,
                  AppColors.primaryLight,
                  AppColors.primaryDark,
                  onTap: () => _confirmCallTeacher(teacher),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildContactButton(
                  LucideIcons.mail,
                  teacher.email,
                  const Color(0xFFF1F5F9),
                  AppColors.textSecondary,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('កំពុងបើកកម្មវិធីអ៊ីមែលទៅកាន់ ${teacher.email}...', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildContactButton(IconData icon, String label, Color bg, Color textColor, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: bg == Colors.white ? AppColors.border : Colors.transparent),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: textColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionBold.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
