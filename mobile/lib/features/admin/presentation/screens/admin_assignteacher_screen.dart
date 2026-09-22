import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:voatmean_mobile/core/constants/app_colors.dart';
import '../widgets/admin_modals.dart';
import '../../data/models/admin_models.dart';

class AdminAssignTeacherScreen extends StatefulWidget {
  const AdminAssignTeacherScreen({super.key});

  @override
  State<AdminAssignTeacherScreen> createState() => _AdminAssignTeacherScreenState();
}

class _AdminAssignTeacherScreenState extends State<AdminAssignTeacherScreen> {
  String _searchQuery = '';
  String _subjectFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<TeacherModel> _teachers = [
    TeacherModel(
      id: 'tch-1',
      name: 'Sok Samnang',
      nameKhmer: 'លោកគ្រូ សុខ សំណាង',
      gender: 'M',
      phone: '012 345 678',
      email: 'sok.samnang@school.edu',
      subject: 'Mathematics',
      subjectKhmer: 'គណិតវិទ្យា',
      assignedClasses: ['Grade 10A', 'Grade 12A'],
      teachingHoursPerWeek: 18,
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBW60befM5ZEuh3cxe1G0lFhJPxhypregWJHKo1-hfuMx2Nz3QkzlB8NeWkXkCk5BQl_PRTXh7PPqYrIg5drnobS_azzQ1KBedpg20vJWfNGNC4vk5_7F8I7Q8bkuWLBti5jbTOUK396MJMdlrBX-yE2a87Sqt5Ki9PuayDZHI35cIW-aeXzcHeERXz1oJ_7ZxU4WqN9usU742nu8iXkUIrJV5DQJkQUN5eeqfpUh-CCPVL1daNeU',
    ),
    TeacherModel(
      id: 'tch-2',
      name: 'Keo Bopha',
      nameKhmer: 'អ្នកគ្រូ កែវ បុប្ផា',
      gender: 'F',
      phone: '098 765 432',
      email: 'keo.bopha@school.edu',
      subject: 'Physics',
      subjectKhmer: 'រូបវិទ្យា',
      assignedClasses: ['Grade 10B'],
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
      assignedTeacherId: 'tch-1',
      assignedTeacherName: 'Sok Samnang',
      assignedTeacherKhmer: 'សុខ សំណាង',
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

  void _deleteTeacher(TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('លុបគ្រូបង្រៀន?', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
        content: Text('តើអ្នកប្រាកដថាចង់លុបលោកគ្រូ/អ្នកគ្រូ ${teacher.nameKhmer}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('បោះបង់')),
          ElevatedButton(
            onPressed: () {
              setState(() => _teachers.removeWhere((t) => t.id == teacher.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('លុប'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Top Header Banner
                  _buildHeaderBanner(),
                  const SizedBox(height: 16),

                  // 2. Search Input
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // 3. Teachers List
                  _buildTeachersList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.users, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'គ្រប់គ្រងគ្រូបង្រៀន (Teachers)',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'សរុបមានគ្រូបង្រៀនចំនួន ${_teachers.length} នាក់ក្នុងប្រព័ន្ធ',
                    style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              IconButton(
                onPressed: _openAddTeacherModal,
                icon: const Icon(LucideIcons.userPlus, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSubtle),
        hintText: 'ស្វែងរកតាមឈ្មោះ លេខទូរស័ព្ទ ឬអុីមែល...',
        hintStyle: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSubtle),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.users, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'មិនមានគ្រូបង្រៀនត្រូវនឹងលក្ខខណ្ឌស្វែងរកទេ',
              textAlign: TextAlign.center,
              style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Row 1: Profile & Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  image: teacher.avatarUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(teacher.avatarUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: teacher.avatarUrl.isEmpty
                    ? Center(
                  child: Text(
                    teacher.name.substring(0, 2).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          teacher.nameKhmer,
                          style: GoogleFonts.kantumruyPro(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            teacher.subjectKhmer,
                            style: GoogleFonts.kantumruyPro(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${teacher.name} • ${teacher.gender == 'M' ? 'ប្រុស (Male)' : 'ស្រី (Female)'}',
                      style: TextStyle(fontSize: 11, color: AppColors.textSubtle),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _openEditTeacherModal(teacher),
                    icon: const Icon(LucideIcons.edit2, size: 16),
                    color: AppColors.textMuted,
                  ),
                  IconButton(
                    onPressed: () => _deleteTeacher(teacher),
                    icon: const Icon(LucideIcons.trash2, size: 16),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Badges
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.bookOpen, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('ថ្នាក់បង្រៀន៖', style: GoogleFonts.kantumruyPro(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    ...teacher.assignedClasses.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
                        child: Text(c, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )),
                    if (teacher.assignedClasses.isEmpty)
                      Text('មិនទាន់កំណត់', style: GoogleFonts.kantumruyPro(fontSize: 11, color: AppColors.textSubtle)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${teacher.teachingHoursPerWeek} hrs/week', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Row 3: Contact Actions
          Row(
            children: [
              Expanded(
                child: _buildContactButton(LucideIcons.phone, teacher.phone, AppColors.primaryLight, AppColors.primaryDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildContactButton(LucideIcons.mail, teacher.email, const Color(0xFFF1F5F9), AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, Color bg, Color textColor) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
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
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
