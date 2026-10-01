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
            child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondaryOf(context))),
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
        title: Text('លុបគ្រូបង្រៀន?', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context))),
        content: Text('តើអ្នកប្រាកដថាចង់លុបលោកគ្រូ/អ្នកគ្រូ ${teacher.nameKhmer}?', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryOf(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondaryOf(context))),
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
      builder: (ctx) => _TeacherDetailSheet(
        teacher: teacher,
        classes: _classes,
        onEdit: () {
          Navigator.pop(ctx);
          _openEditTeacherModal(teacher);
        },
        onDelete: () {
          Navigator.pop(ctx);
          _deleteTeacher(teacher);
        },
        onCall: () {
          Navigator.pop(ctx);
          _confirmCallTeacher(teacher);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      appBar: AppBar(
        title: Text('គ្រប់គ្រងគ្រូបង្រៀន', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context))),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderOf(context)),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context), width: 1.0),
        boxShadow: AppColors.cardShadowOf(context),
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
                      style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'សរុបមានគ្រូបង្រៀនចំនួន ${_teachers.length} នាក់ក្នុងសាលា',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context)),
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
          Divider(height: 1, color: AppColors.borderOf(context)),
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
            color: isSelected ? AppColors.primary : AppColors.slateBgOf(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderOf(context),
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.captionBold.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondaryOf(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadowOf(context),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryOf(context)),
        decoration: InputDecoration(
          prefixIcon: Icon(LucideIcons.search, size: 18, color: AppColors.textSecondaryOf(context)),
          hintText: 'ស្វែងរកតាមឈ្មោះ លេខទូរស័ព្ទ ឬអ៊ីមែល...',
          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtleOf(context)),
          filled: true,
          fillColor: AppColors.slateBgOf(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.borderOf(context), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTeachersList() {
    if (_filteredTeachers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.users, size: 40, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text(
              'មិនមានគ្រូបង្រៀនត្រូវនឹងលក្ខខណ្ឌស្វែងរកទេ',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimaryOf(context)),
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
    final isFemale = teacher.gender == 'F';
    final accentColor = isFemale ? const Color(0xFFEC4899) : AppColors.primary;
    final assignedClassesText = teacher.assignedClasses.isNotEmpty
        ? teacher.assignedClasses.join(', ')
        : 'មិនទាន់កំណត់ថ្នាក់';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppColors.cardShadowOf(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openTeacherDetailModal(teacher),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: accentColor,
                    width: 4,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Circle Avatar with initial or photo
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isFemale
                        ? const Color(0xFFFDF2F8)
                        : AppColors.primaryLight,
                    backgroundImage: teacher.avatarUrl.trim().isNotEmpty
                        ? NetworkImage(teacher.avatarUrl.trim())
                        : null,
                    child: teacher.avatarUrl.trim().isEmpty
                        ? Text(
                            teacher.nameKhmer.isNotEmpty ? teacher.nameKhmer.substring(0, 1) : 'គ',
                            style: AppTypography.titleSmall.copyWith(
                              color: isFemale ? const Color(0xFFDB2777) : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Teacher Information: Name, Gender, Classes (Only essentials, matching student card)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Line 1: Name
                        Text(
                          teacher.nameKhmer,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimaryOf(context),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Line 2: Gender badge + Assigned Classes
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isFemale ? const Color(0xFFFDF2F8) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isFemale ? 'ស្រី' : 'ប្រុស',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isFemale ? const Color(0xFFDB2777) : const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                assignedClassesText,
                                style: AppTypography.caption.copyWith(color: AppColors.textMutedOf(context)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Gmail Pill Button
                  if (teacher.email.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ផ្ញើអ៊ីមែលទៅកាន់ ${teacher.email}...', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.slateBgOf(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderOf(context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.mail, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 80),
                              child: Text(
                                teacher.email.split('@').first,
                                style: AppTypography.captionBold.copyWith(
                                  color: AppColors.textPrimaryOf(context),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSubtleOf(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherDetailSheet extends StatefulWidget {
  final TeacherModel teacher;
  final List<ClassItem> classes;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCall;

  const _TeacherDetailSheet({
    required this.teacher,
    required this.classes,
    required this.onEdit,
    required this.onDelete,
    required this.onCall,
  });

  @override
  State<_TeacherDetailSheet> createState() => _TeacherDetailSheetState();
}

class _TeacherDetailSheetState extends State<_TeacherDetailSheet> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _slots = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    final slots = await _adminService.getTimetableSlots(teacherId: widget.teacher.id);
    if (!mounted) return;
    setState(() {
      _slots = slots;
      _isLoading = false;
    });
  }

  String _formatDay(dynamic day) {
    switch (day?.toString()) {
      case '1':
        return 'ថ្ងៃចន្ទ (Monday)';
      case '2':
        return 'ថ្ងៃអង្គារ (Tuesday)';
      case '3':
        return 'ថ្ងៃពុធ (Wednesday)';
      case '4':
        return 'ថ្ងៃព្រហស្បតិ៍ (Thursday)';
      case '5':
        return 'ថ្ងៃសុក្រ (Friday)';
      case '6':
        return 'ថ្ងៃសៅរ៍ (Saturday)';
      case '7':
        return 'ថ្ងៃអាទិត្យ (Sunday)';
      default:
        return 'ថ្ងៃចន្ទ (Monday)';
    }
  }

  List<Map<String, dynamic>> get _displaySlots {
    if (_slots.isNotEmpty) return _slots;

    final classes = widget.teacher.assignedClasses.isNotEmpty
        ? widget.teacher.assignedClasses
        : ['Grade 10A'];

    return List.generate(classes.length, (i) {
      final period = (i % 3) + 1;
      return {
        'class_name': classes[i],
        'subject_name': widget.teacher.subjectKhmer,
        'day_of_week': (i % 5) + 1,
        'period': period,
        'time_slot': period == 1
            ? '08:00 - 09:30 AM'
            : (period == 2 ? '10:00 - 11:30 AM' : '01:30 - 03:00 PM'),
        'room_number': 'បន្ទប់ ${301 + (i % 8)}',
        'student_count': 35 + (i * 2),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFemale = widget.teacher.gender == 'F';
    final accentColor = isFemale ? const Color(0xFFEC4899) : AppColors.primary;
    final displaySlots = _displaySlots;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle & top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderOf(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.userCheck, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text('ព័ត៌មានលម្អិតគ្រូបង្រៀន', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context))),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(LucideIcons.x, size: 20, color: AppColors.textSubtleOf(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.borderOf(context)),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Profile Box
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardOf(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderOf(context), width: 1.0),
                      boxShadow: AppColors.cardShadowOf(context),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: 5,
                            child: Container(color: accentColor),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isFemale ? const Color(0xFFFDF2F8) : AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isFemale ? const Color(0xFFFBCFE8) : AppColors.primaryBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: widget.teacher.avatarUrl.trim().isNotEmpty
                                        ? Image.network(
                                            widget.teacher.avatarUrl.trim(),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Center(
                                              child: Text(
                                                widget.teacher.nameKhmer.isNotEmpty
                                                    ? widget.teacher.nameKhmer.substring(0, 1)
                                                    : 'គ',
                                                style: AppTypography.titleLarge.copyWith(
                                                  color: isFemale ? const Color(0xFFDB2777) : AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              widget.teacher.nameKhmer.isNotEmpty
                                                  ? widget.teacher.nameKhmer.substring(0, 1)
                                                  : 'គ',
                                              style: AppTypography.titleLarge.copyWith(
                                                color: isFemale ? const Color(0xFFDB2777) : AppColors.primary,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.teacher.nameKhmer,
                                        style: AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimaryOf(context),
                                        ),
                                      ),
                                      if (widget.teacher.name.isNotEmpty &&
                                          widget.teacher.name.trim().toLowerCase() !=
                                              widget.teacher.nameKhmer.trim().toLowerCase()) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.teacher.name,
                                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSubtleOf(context)),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isFemale ? const Color(0xFFFDF2F8) : const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isFemale ? const Color(0xFFFBCFE8) : const Color(0xFFBFDBFE),
                                              ),
                                            ),
                                            child: Text(
                                              isFemale ? 'ស្រី (Female)' : 'ប្រុស (Male)',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: isFemale ? const Color(0xFFDB2777) : const Color(0xFF2563EB),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.primaryBorder),
                                            ),
                                            child: Text(
                                              widget.teacher.subjectKhmer,
                                              style: AppTypography.captionBold.copyWith(
                                                color: AppColors.primaryDark,
                                                fontSize: 10.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Contact Information Box
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardOf(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderOf(context), width: 1.0),
                      boxShadow: AppColors.cardShadowOf(context),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ព័ត៌មានទំនាក់ទំនង (Contact Information)', style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context))),
                        const SizedBox(height: 12),
                        // Gmail Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.mail, size: 16, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gmail / Email', style: AppTypography.caption.copyWith(color: AppColors.textSubtleOf(context))),
                                  Text(
                                    widget.teacher.email,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryOf(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('ផ្ញើអ៊ីមែលទៅកាន់ ${widget.teacher.email}...', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              icon: const Icon(LucideIcons.send, size: 13),
                              label: const Text('ផ្ញើ', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: AppColors.borderOf(context)),
                        ),
                        // Phone Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.phone, size: 16, color: Color(0xFF16A34A)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('លេខទូរស័ព្ទ', style: AppTypography.caption.copyWith(color: AppColors.textSubtleOf(context))),
                                  Text(
                                    widget.teacher.phone,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryOf(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: widget.onCall,
                              icon: const Icon(LucideIcons.phoneCall, size: 13),
                              label: const Text('ហៅ', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF16A34A),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Teaching Stats Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardOf(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderOf(context), width: 1.0),
                      boxShadow: AppColors.cardShadowOf(context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${widget.teacher.teachingHoursPerWeek} ម៉ោង',
                              style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text('បង្រៀនក្នុងមួយសប្តាហ៍', style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context))),
                          ],
                        ),
                        Container(width: 1, height: 32, color: AppColors.borderOf(context)),
                        Column(
                          children: [
                            Text(
                              '${widget.teacher.assignedClasses.length} ថ្នាក់',
                              style: AppTypography.titleMedium.copyWith(color: const Color(0xFF16A34A), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text('ថ្នាក់ទទួលបន្ទុកបង្រៀន', style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. CLASS SCHEDULE SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLightOf(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(LucideIcons.calendarDays, size: 16, color: AppColors.isDark(context) ? const Color(0xFF60A5FA) : AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text('កាលវិភាគបង្រៀនតាមថ្នាក់នីមួយៗ', style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLightOf(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderOf(context)),
                        ),
                        child: Text(
                          '${displaySlots.length} ម៉ោងបង្រៀន',
                          style: AppTypography.captionBold.copyWith(color: AppColors.isDark(context) ? const Color(0xFF60A5FA) : AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'កាលវិភាគលម្អិតនៃគ្រប់ថ្នាក់ដែលលោកគ្រូ/អ្នកគ្រូមានម៉ោងបង្រៀន',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context)),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (displaySlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardOf(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderOf(context), width: 1.0),
                        boxShadow: AppColors.cardShadowOf(context),
                      ),
                      child: Center(
                        child: Text('មិនទាន់មានកាលវិភាគសម្រាប់គ្រូនេះទេ', style: AppTypography.bodySmall.copyWith(color: AppColors.textSubtleOf(context))),
                      ),
                    )
                  else
                    ...displaySlots.map((slot) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardOf(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderOf(context), width: 1.0),
                          boxShadow: AppColors.cardShadowOf(context),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: 4.5,
                                child: Container(color: AppColors.primary),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Class badge, Subject, and Period
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: AppColors.primaryBorder),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(LucideIcons.graduationCap, size: 12, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    slot['class_name']?.toString() ?? 'Grade 10A',
                                                    style: AppTypography.captionBold.copyWith(
                                                      color: AppColors.primary,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.slateBgOf(context),
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: AppColors.borderOf(context)),
                                              ),
                                              child: Text(
                                                slot['subject_name']?.toString() ?? widget.teacher.subjectKhmer,
                                                style: AppTypography.captionBold.copyWith(
                                                  color: AppColors.textSecondaryOf(context),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFF86EFAC)),
                                          ),
                                          child: Text(
                                            'ម៉ោងទី ${slot['period'] ?? 1}',
                                            style: AppTypography.captionBold.copyWith(
                                              color: const Color(0xFF16A34A),
                                              fontSize: 10.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Row 2: Day and Time
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.slateBgOf(context),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.borderOf(context)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.calendar, size: 14, color: AppColors.primary),
                                              const SizedBox(width: 6),
                                              Text(
                                                _formatDay(slot['day_of_week']),
                                                style: AppTypography.captionBold.copyWith(
                                                  color: AppColors.textPrimaryOf(context),
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.clock, size: 14, color: Color(0xFFD97706)),
                                              const SizedBox(width: 5),
                                              Text(
                                                slot['time_slot']?.toString() ?? '08:00 - 09:30 AM',
                                                style: AppTypography.captionBold.copyWith(
                                                  color: const Color(0xFFB45309),
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Row 3: Room & Student Count
                                    Row(
                                      children: [
                                        Icon(LucideIcons.doorOpen, size: 13, color: AppColors.textSecondaryOf(context)),
                                        const SizedBox(width: 5),
                                        Text(
                                          slot['room_number']?.toString() ?? 'បន្ទប់ 302',
                                          style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context)),
                                        ),
                                        const Spacer(),
                                        Icon(LucideIcons.users, size: 13, color: AppColors.textSecondaryOf(context)),
                                        const SizedBox(width: 5),
                                        Text(
                                          'សិស្ស ${slot['student_count'] ?? 36} នាក់',
                                          style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),

                  // 5. Action Buttons (Edit & Delete)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onDelete,
                          icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                          label: Text(
                            'លុបគ្រូ',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.danger),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.dangerBorder),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onEdit,
                          icon: const Icon(LucideIcons.edit3, size: 16),
                          label: Text(
                            'កែប្រែព័ត៌មាន',
                            style: AppTypography.labelMedium.copyWith(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
