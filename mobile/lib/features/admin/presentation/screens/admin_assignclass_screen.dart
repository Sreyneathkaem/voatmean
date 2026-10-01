import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import '../../data/models/admin_models.dart';
import '../../data/services/admin_service.dart';
import '../widgets/admin_modals.dart';

class AdminAssignClassScreen extends StatefulWidget {
  const AdminAssignClassScreen({super.key});

  @override
  State<AdminAssignClassScreen> createState() =>
      _AdminAssignClassScreenState();
}

class _AdminAssignClassScreenState extends State<AdminAssignClassScreen> {
  final AdminService _adminService = AdminService();
  String _selectedAcademicYear = '2026–2027';
  String _selectedGradeFilter = 'all'; // 'all', '10', '11', '12'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<TeacherModel> _teachers = [];

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
        _teachers = teachersData.map((t) {
          final fullName = t['full_name']?.toString() ?? 'គ្រូបង្រៀន';
          final isFemale = fullName.contains('អ្នកគ្រូ') ||
              fullName.toLowerCase().contains('srey') ||
              fullName.toLowerCase().contains('yung');
          return TeacherModel(
            id: t['user_id']?.toString() ?? '',
            name: fullName,
            nameKhmer: fullName,
            gender: isFemale ? 'F' : 'M',
            phone: '012 345 678',
            email: t['email']?.toString() ?? '',
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
          );
        }).toList();
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

  // Mock initial classes
  final List<ClassItem> _classes = [
    ClassItem(
      id: 'c-1',
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
    ClassItem(
      id: 'c-2',
      grade: 'Grade 10B',
      gradeKhmer: 'ថ្នាក់ ១០ ខ',
      subject: 'រូបវិទ្យា',
      subjectKhmer: 'រូបវិទ្យា',
      academicYear: '2026–2027',
      assignedTeacherId: '83a60985-e10d-47ed-96d2-f888aef71a78',
      assignedTeacherName: 'Yung Sreyneang',
      assignedTeacherKhmer: 'អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)',
      hoursPerWeek: 4,
      totalStudents: 35,
    ),
    ClassItem(
      id: 'c-3',
      grade: 'Grade 11A',
      gradeKhmer: 'ថ្នាក់ ១១ ក',
      subject: 'ភាសាខ្មែរ',
      subjectKhmer: 'ភាសាខ្មែរ',
      academicYear: '2026–2027',
      assignedTeacherId: '8f7bcc0f-c914-4757-9738-d7f257c4c1a2',
      assignedTeacherName: 'Kaem Sreyneath',
      assignedTeacherKhmer: 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)',
      hoursPerWeek: 5,
      totalStudents: 38,
    ),
    ClassItem(
      id: 'c-4',
      grade: 'Grade 12A',
      gradeKhmer: 'ថ្នាក់ ១២ ក',
      subject: 'ជីវវិទ្យា',
      subjectKhmer: 'ជីវវិទ្យា',
      academicYear: '2026–2027',
      assignedTeacherId: '83a60985-e10d-47ed-96d2-f888aef71a78',
      assignedTeacherName: 'Yung Sreyneang',
      assignedTeacherKhmer: 'អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)',
      hoursPerWeek: 7,
      totalStudents: 40,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClassItem> get _filteredClasses {
    return _classes.where((c) {
      final matchesYear = c.academicYear == _selectedAcademicYear;
      final matchesGrade = _selectedGradeFilter == 'all'
          ? true
          : c.grade.contains(_selectedGradeFilter) ||
          c.gradeKhmer.contains(_selectedGradeFilter);

      final q = _searchQuery.toLowerCase();
      final matchesSearch = c.grade.toLowerCase().contains(q) ||
          c.gradeKhmer.toLowerCase().contains(q) ||
          c.subject.toLowerCase().contains(q) ||
          c.assignedTeacherKhmer.toLowerCase().contains(q) ||
          c.assignedTeacherName.toLowerCase().contains(q);

      return matchesYear && matchesGrade && matchesSearch;
    }).toList();
  }

  void _deleteClass(String id, String className) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('លុបថ្នាក់រៀន?', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context))),
        content: Text('តើអ្នកប្រាកដថាចង់លុបថ្នាក់ $className?', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryOf(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondaryOf(context))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _classes.removeWhere((c) => c.id == id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('បានលុបថ្នាក់រៀនដោយជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: Text('លុប', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Modal: Reassign Teacher / Hours ---
  void _openAssignTeacherModal(ClassItem classItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AssignTeacherBottomSheet(
        targetClass: classItem,
        teachers: _teachers.isNotEmpty ? _teachers : [
          TeacherModel(
            id: '8f7bcc0f-c914-4757-9738-d7f257c4c1a2',
            name: 'Kaem Sreyneath',
            nameKhmer: 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)',
            gender: 'F',
            phone: '012 345 678',
            email: 'k.sreyneath24@gmail.com',
            subject: 'Mathematics',
            subjectKhmer: 'គណិតវិទ្យា',
            assignedClasses: ['Grade 10A'],
            teachingHoursPerWeek: 18,
            avatarUrl: '',
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
            assignedClasses: ['Grade 10B'],
            teachingHoursPerWeek: 16,
            avatarUrl: '',
          ),
        ],
        onUpdated: (updated) {
          setState(() {
            final idx = _classes.indexWhere((c) => c.id == updated.id);
            if (idx != -1) {
              _classes[idx] = updated;
            }
          });
        },
      ),
    );
  }

  // --- Modal: Create New Class ---
  void _openCreateClassModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateClassBottomSheet(
        teachers: _teachers.isNotEmpty ? _teachers : [
          TeacherModel(
            id: '8f7bcc0f-c914-4757-9738-d7f257c4c1a2',
            name: 'Kaem Sreyneath',
            nameKhmer: 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)',
            gender: 'F',
            phone: '012 345 678',
            email: 'k.sreyneath24@gmail.com',
            subject: 'Mathematics',
            subjectKhmer: 'គណិតវិទ្យា',
            assignedClasses: ['Grade 10A'],
            teachingHoursPerWeek: 18,
            avatarUrl: '',
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
            assignedClasses: ['Grade 10B'],
            teachingHoursPerWeek: 16,
            avatarUrl: '',
          ),
        ],
        onCreated: (newClass) {
          setState(() {
            _classes.insert(0, newClass);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'ចាត់តាំងថ្នាក់រៀន',
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderOf(context)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Header Card
            _buildHeaderCard(),
            const SizedBox(height: 14),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 14),

            // Class Cards List
            _buildClassList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppColors.cardShadowOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.graduationCap,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ចាត់តាំងវគ្គសិក្សា និងគ្រូ',
                            style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context)),
                          ),
                          Text(
                            'គ្រប់គ្រងការបែងចែកថ្នាក់រៀន និងម៉ោងបង្រៀន',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _openCreateClassModal,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: Text(
                  'ថ្នាក់ថ្មី',
                  style: AppTypography.labelSmall.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.borderOf(context)),
          const SizedBox(height: 12),

          // Year Selector & Grade Chips
          Row(
            children: [
              // Year Selector
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slateBgOf(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: AppColors.cardOf(context),
                    value: _selectedAcademicYear,
                    style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context)),
                    icon: Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondaryOf(context)),
                    items: ['2026–2027', '2025–2026', '2024–2025'].map((y) {
                      return DropdownMenuItem(
                          value: y,
                          child: Text('ឆ្នាំសិក្សា $y',
                              style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context))));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedAcademicYear = v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Grade Filter Chips Scroll
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildGradeChip('គ្រប់ថ្នាក់', 'all'),
                      const SizedBox(width: 6),
                      _buildGradeChip('ថ្នាក់ទី ១០', '10'),
                      const SizedBox(width: 6),
                      _buildGradeChip('ថ្នាក់ទី ១១', '11'),
                      const SizedBox(width: 6),
                      _buildGradeChip('ថ្នាក់ទី ១២', '12'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeChip(String label, String value) {
    final isSelected = _selectedGradeFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedGradeFilter = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.slateBgOf(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTypography.captionBold.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryOf(context)),
      decoration: InputDecoration(
        prefixIcon: Icon(LucideIcons.search,
            size: 18, color: AppColors.textSecondaryOf(context)),
        hintText: 'ស្វែងរកតាមឈ្មោះថ្នាក់ មុខវិជ្ជា ឬគ្រូបង្រៀន...',
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtleOf(context)),
        filled: true,
        fillColor: AppColors.slateBgOf(context),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.borderOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildClassList() {
    if (_filteredClasses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.bookOpen,
                size: 40, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 8),
            Text(
              'មិនមានទិន្នន័យថ្នាក់រៀនទេ',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryOf(context)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredClasses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final item = _filteredClasses[index];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadowOf(context),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: Container(color: const Color(0xFF4F46E5)),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openAssignTeacherModal(item),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18, right: 16, top: 16, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    // Class title & actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                item.grade,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryOf(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFC7D2FE)),
                                  ),
                                  child: Text(
                                    item.subject,
                                    style: AppTypography.captionBold.copyWith(
                                      color: const Color(0xFF4F46E5),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _openAssignTeacherModal(item),
                              icon: const Icon(LucideIcons.edit3, size: 17),
                              color: AppColors.primary,
                              tooltip: 'កែសម្រួល',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              onPressed: () => _deleteClass(
                                  item.id, '${item.grade} (${item.subject})'),
                              icon: const Icon(LucideIcons.trash2, size: 17),
                              color: AppColors.danger,
                              tooltip: 'លុប',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Teacher & hours detail grid
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.slateBgOf(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderOf(context)),
                      ),
                      child: Row(
                        children: [
                          // Teacher
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLightOf(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(LucideIcons.userCheck,
                                      size: 14, color: AppColors.isDark(context) ? const Color(0xFF60A5FA) : AppColors.primary),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'គ្រូបង្រៀន',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textSecondaryOf(context),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        item.assignedTeacherKhmer,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimaryOf(context),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Container(
                            height: 24,
                            width: 1,
                            color: AppColors.borderOf(context),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                          ),

                          // Hours
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningBgOf(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(LucideIcons.clock,
                                      size: 14, color: AppColors.warningTextOf(context)),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ម៉ោង/សប្តាហ៍',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textSecondaryOf(context),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        '${item.hoursPerWeek} ម៉ោង',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimaryOf(context),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Container(
                            height: 24,
                            width: 1,
                            color: AppColors.borderOf(context),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                          ),

                          // Students
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBgOf(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(LucideIcons.users,
                                      size: 14, color: AppColors.successTextOf(context)),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'សិស្សសរុប',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textSecondaryOf(context),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    const SizedBox(height: 1),
                                    Text(
                                      '${item.totalStudents} នាក់',
                                      style:
                                          AppTypography.labelSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimaryOf(context),
                                      ),
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
                    const SizedBox(height: 10),

                    // Reassign action button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _openAssignTeacherModal(item),
                        icon: const Icon(LucideIcons.arrowRight, size: 14),
                        label: Text(
                          'ប្តូរគ្រូបង្រៀន ឬម៉ោងសិក្សា',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
},
);
  }
}
