import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:voatmean_mobile/core/constants/app_colors.dart';
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

  void _deleteClass(String id) {
    setState(() {
      _classes.removeWhere((c) => c.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('បានលុបថ្នាក់រៀនដោយជោគជ័យ',
            style: GoogleFonts.kantumruyPro()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
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
          'ចាត់តាំងវគ្គសិក្សា (Course Assignment)',
          style: GoogleFonts.kantumruyPro(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.graduationCap,
                      color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ចាត់តាំងវគ្គសិក្សា និងគ្រូ',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'គ្រប់គ្រងការបែងចែកថ្នាក់រៀន និងម៉ោងបង្រៀន',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _openCreateClassModal,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: Text(
                  'ថ្នាក់ថ្មី',
                  style: GoogleFonts.kantumruyPro(
                      fontSize: 11, fontWeight: FontWeight.bold),
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
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.kantumruyPro(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: const Icon(LucideIcons.search,
            size: 18, color: AppColors.textSubtle),
        hintText: 'ស្វែងរកតាមឈ្មោះថ្នាក់ មុខវិជ្ជា ឬគ្រូបង្រៀន...',
        hintStyle: GoogleFonts.kantumruyPro(
          fontSize: 12,
          color: AppColors.textSubtle,
        ),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.bookOpen,
                size: 40, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 8),
            Text(
              'មិនមានទិន្នន័យថ្នាក់រៀនទេ',
              style: GoogleFonts.kantumruyPro(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredClasses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, index) {
        final item = _filteredClasses[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class title & actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        item.grade,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryBorder),
                        ),
                        child: Text(
                          item.subject,
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _openAssignTeacherModal(item),
                        icon: const Icon(LucideIcons.edit3, size: 16),
                        color: AppColors.primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _deleteClass(item.id),
                        icon: const Icon(LucideIcons.trash2, size: 16),
                        color: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Teacher & hours detail grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    // Teacher
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          const Icon(LucideIcons.user,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('គ្រូបង្រៀន',
                                    style: GoogleFonts.kantumruyPro(
                                        fontSize: 9,
                                        color: AppColors.textSubtle)),
                                Text(
                                  item.assignedTeacherKhmer,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.kantumruyPro(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Hours
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          const Icon(LucideIcons.clock,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ម៉ោង/សប្តាហ៍',
                                  style: GoogleFonts.kantumruyPro(
                                      fontSize: 9,
                                      color: AppColors.textSubtle)),
                              Text(
                                '${item.hoursPerWeek} ម៉ោង',
                                style: GoogleFonts.kantumruyPro(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Students
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          const Icon(LucideIcons.users,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('សិស្សសរុប',
                                  style: GoogleFonts.kantumruyPro(
                                      fontSize: 9,
                                      color: AppColors.textSubtle)),
                              Text(
                                '${item.totalStudents} នាក់',
                                style: GoogleFonts.kantumruyPro(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
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
              const SizedBox(height: 8),

              // Reassign action button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _openAssignTeacherModal(item),
                  icon: const Icon(LucideIcons.arrowRight, size: 14),
                  label: Text(
                    'ប្តូរគ្រូបង្រៀន ឬម៉ោងសិក្សា',
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
