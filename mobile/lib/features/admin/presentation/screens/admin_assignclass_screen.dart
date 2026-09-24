import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import '../../data/models/admin_models.dart';
import '../widgets/admin_modals.dart';

class AdminAssignClassScreen extends StatefulWidget {
  const AdminAssignClassScreen({super.key});

  @override
  State<AdminAssignClassScreen> createState() =>
      _AdminAssignClassScreenState();
}

class _AdminAssignClassScreenState extends State<AdminAssignClassScreen> {
  String _selectedAcademicYear = '2026–2027';
  String _selectedGradeFilter = 'all'; // 'all', '10', '11', '12'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Mock initial classes
  final List<ClassItem> _classes = [
    ClassItem(
      id: 'c-1',
      grade: 'Grade 10A',
      gradeKhmer: 'ថ្នាក់ ១០ ក',
      subject: 'គណិតវិទ្យា',
      subjectKhmer: 'គណិតវិទ្យា',
      academicYear: '2026–2027',
      assignedTeacherId: 'tch-1',
      assignedTeacherName: 'Sok Samnang',
      assignedTeacherKhmer: 'លោកគ្រូ សុខ សំណាង',
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
      assignedTeacherId: 'tch-2',
      assignedTeacherName: 'Keo Bopha',
      assignedTeacherKhmer: 'អ្នកគ្រូ កែវ បុប្ផា',
      hoursPerWeek: 4,
      totalStudents: 35,
    ),
    ClassItem(
      id: 'c-3',
      grade: 'Grade 11A',
      gradeKhmer: 'ថ្នាក់ ១១ ក',
      subject: 'គីមីវិទ្យា',
      subjectKhmer: 'គីមីវិទ្យា',
      academicYear: '2026–2027',
      assignedTeacherId: 'tch-3',
      assignedTeacherName: 'Chan Sreymom',
      assignedTeacherKhmer: 'អ្នកគ្រូ ចាន់ ស្រីមុំ',
      hoursPerWeek: 5,
      totalStudents: 38,
    ),
    ClassItem(
      id: 'c-4',
      grade: 'Grade 12A',
      gradeKhmer: 'ថ្នាក់ ១២ ក',
      subject: 'គណិតវិទ្យាជាន់ខ្ពស់',
      subjectKhmer: 'គណិតវិទ្យាជាន់ខ្ពស់',
      academicYear: '2026–2027',
      assignedTeacherId: 'tch-1',
      assignedTeacherName: 'Sok Samnang',
      assignedTeacherKhmer: 'លោកគ្រូ សុខ សំណាង',
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
        title: Text('លុបថ្នាក់រៀន?', style: AppTypography.titleMedium),
        content: Text('តើអ្នកប្រាកដថាចង់លុបថ្នាក់ $className?', style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
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
    final List<TeacherModel> teachersList = [
      TeacherModel(
        id: 'tch-1',
        name: 'Sok Samnang',
        nameKhmer: 'លោកគ្រូ សុខ សំណាង',
        gender: 'M',
        phone: '012345678',
        email: 'sok.samnang@school.edu',
        subject: 'Mathematics',
        subjectKhmer: 'គណិតវិទ្យា',
        assignedClasses: ['Grade 10A'],
        teachingHoursPerWeek: 20,
        avatarUrl: '',
      ),
      TeacherModel(
        id: 'tch-2',
        name: 'Keo Bopha',
        nameKhmer: 'អ្នកគ្រូ កែវ បុប្ផា',
        gender: 'F',
        phone: '012345679',
        email: 'keo.bopha@school.edu',
        subject: 'Physics',
        subjectKhmer: 'រូបវិទ្យា',
        assignedClasses: ['Grade 10B'],
        teachingHoursPerWeek: 18,
        avatarUrl: '',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AssignTeacherBottomSheet(
        targetClass: classItem,
        teachers: teachersList,
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
    final List<TeacherModel> teachersList = [
      TeacherModel(
        id: 'tch-1',
        name: 'Sok Samnang',
        nameKhmer: 'លោកគ្រូ សុខ សំណាង',
        gender: 'M',
        phone: '012345678',
        email: 'sok.samnang@school.edu',
        subject: 'Mathematics',
        subjectKhmer: 'គណិតវិទ្យា',
        assignedClasses: ['Grade 10A'],
        teachingHoursPerWeek: 20,
        avatarUrl: '',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateClassBottomSheet(
        teachers: teachersList,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ចាត់តាំងថ្នាក់រៀន',
          style: AppTypography.titleMedium,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
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
                            style: AppTypography.titleSmall,
                          ),
                          Text(
                            'គ្រប់គ្រងការបែងចែកថ្នាក់រៀន និងម៉ោងបង្រៀន',
                            style: AppTypography.caption,
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
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Year Selector & Grade Chips
          Row(
            children: [
              // Year Selector
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAcademicYear,
                    style: AppTypography.titleSmall,
                    items: ['2026–2027', '2025–2026', '2024–2025'].map((y) {
                      return DropdownMenuItem(
                          value: y, child: Text('ឆ្នាំសិក្សា $y'));
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
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        prefixIcon: const Icon(LucideIcons.search,
            size: 18, color: AppColors.textSubtle),
        hintText: 'ស្វែងរកតាមឈ្មោះថ្នាក់ មុខវិជ្ជា ឬគ្រូបង្រៀន...',
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildClassList() {
    if (_filteredClasses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.bookOpen,
                size: 40, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 8),
            Text(
              'មិនមានទិន្នន័យថ្នាក់រៀនទេ',
              style: AppTypography.bodyMedium,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.border),
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
                                  color: const Color(0xFF0F172A),
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
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.userCheck,
                                      size: 14, color: AppColors.primary),
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
                                          color: AppColors.textSubtle,
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
                                          color: const Color(0xFF0F172A),
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
                            color: const Color(0xFFE2E8F0),
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
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.clock,
                                      size: 14, color: Color(0xFFD97706)),
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
                                          color: AppColors.textSubtle,
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
                                          color: const Color(0xFF0F172A),
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
                            color: const Color(0xFFE2E8F0),
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
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.users,
                                      size: 14, color: Color(0xFF059669)),
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
                                          color: AppColors.textSubtle,
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
                                        color: const Color(0xFF0F172A),
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
