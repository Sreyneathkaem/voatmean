import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import 'package:voatmean_mobile/features/teacher/data/services/teacher_service.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final TeacherService _teacherService = TeacherService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedClass = 'all';
  List<Map<String, dynamic>> _students = [];

  final List<Map<String, dynamic>> _defaultStudents = [
    {
      'student_id': 'STU001',
      'full_name': 'Chan Sreymom',
      'nameKhmer': 'ចាន់ ស្រីមុំ',
      'roll_number': '01',
      'gender': 'F',
      'phone_number': '012 111 222',
      'class_name': 'Grade 10A',
    },
    {
      'student_id': 'STU002',
      'full_name': 'Heng Piseth',
      'nameKhmer': 'ហេង ពិសិដ្ឋ',
      'roll_number': '02',
      'gender': 'M',
      'phone_number': '012 555 666',
      'class_name': 'Grade 10A',
    },
    {
      'student_id': 'STU003',
      'full_name': 'Sok Samnang',
      'nameKhmer': 'សុខ សំណាង',
      'roll_number': '03',
      'gender': 'M',
      'phone_number': '012 345 678',
      'class_name': 'Grade 10A',
    },
    {
      'student_id': 'STU004',
      'full_name': 'Keo Bopha',
      'nameKhmer': 'កែវ បុប្ផា',
      'roll_number': '04',
      'gender': 'F',
      'phone_number': '098 765 432',
      'class_name': 'Grade 12A',
    },
    {
      'student_id': 'STU005',
      'full_name': 'Chea Vannak',
      'nameKhmer': 'ជា វណ្ណៈ',
      'roll_number': '05',
      'gender': 'M',
      'phone_number': '077 889 900',
      'class_name': 'Grade 12A',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final data = await _teacherService.getStudentsByClass('class-1');
    if (mounted) {
      setState(() {
        _students = data.isNotEmpty ? data : _defaultStudents;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((student) {
      final nameKhmer = (student['nameKhmer'] ?? '').toString().toLowerCase();
      final fullName = (student['full_name'] ?? '').toString().toLowerCase();
      final id = (student['student_id'] ?? '').toString().toLowerCase();
      final phone = (student['phone_number'] ?? '').toString().toLowerCase();
      final cls = (student['class_name'] ?? 'Grade 10A').toString();

      final matchesClass = _selectedClass == 'all' || cls == _selectedClass;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          nameKhmer.contains(q) ||
          fullName.contains(q) ||
          id.contains(q) ||
          phone.contains(q);

      return matchesClass && matchesSearch;
    }).toList();
  }

  void _callPhone(String phone, String name) {
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
            Text('ទាក់ទងសិស្ស', style: AppTypography.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('តើលោកអ្នកចង់ហៅទូរស័ព្ទទៅកាន់ $name មែនទេ?', style: AppTypography.bodyMedium),
            const SizedBox(height: 8),
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
                  Text(phone, style: AppTypography.titleSmall.copyWith(color: AppColors.primary)),
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
                  content: Text('កំពុងហៅចេញទៅកាន់ $phone...', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
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

  void _showStudentDetailModal(Map<String, dynamic> student) {
    final nameKhmer = student['nameKhmer'] ?? student['full_name'] ?? 'សិស្ស';
    final fullName = student['full_name'] ?? '';
    final gender = student['gender'] ?? 'M';
    final isFemale = gender == 'F';
    final rollNumber = student['roll_number'] ?? '01';
    final studentId = student['student_id'] ?? 'STU001';
    final phone = student['phone_number']?.toString() ?? '012 345 678';
    final className = student['class_name'] ?? 'Grade 10A';

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
            // Top Bar
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
                  radius: 30,
                  backgroundColor: isFemale ? const Color(0xFFFDF2F8) : AppColors.primaryLight,
                  child: Text(
                    nameKhmer.isNotEmpty ? nameKhmer.substring(0, 1) : 'ស',
                    style: AppTypography.titleLarge.copyWith(
                      color: isFemale ? const Color(0xFFDB2777) : AppColors.primary,
                    ),
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
                            child: Text(nameKhmer, style: AppTypography.titleMedium),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              className,
                              style: AppTypography.captionBold.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$fullName • លេខរៀង #$rollNumber',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                      Text(
                        'អត្តលេខ៖ $studentId',
                        style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
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

            // Attendance Statistics Grid
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
                  _buildStatItem('វត្តមាន', '94%', AppColors.success),
                  _buildStatItem('មានវត្តមាន', '32 ថ្ងៃ', AppColors.primary),
                  _buildStatItem('យឺត', '2 ថ្ងៃ', AppColors.warning),
                  _buildStatItem('អវត្តមាន', '1 ថ្ងៃ', AppColors.danger),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Contact Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.phone, size: 16, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text('លេខទូរស័ព្ទ៖ ', style: AppTypography.caption),
                  Text(phone, style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _callPhone(phone, nameKhmer);
                    },
                    icon: const Icon(LucideIcons.phoneCall, size: 16),
                    label: Text('ហៅទូរស័ព្ទ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('កំពុងបើកការផ្ញើសារទៅកាន់ $nameKhmer...', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.messageSquare, size: 16),
                    label: Text('ផ្ញើសារ', style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
      ],
    );
  }

  void _openAddStudentModal() {
    final nameCtrl = TextEditingController();
    final nameKhmerCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final rollCtrl = TextEditingController(text: '${_students.length + 1}'.padLeft(2, '0'));
    String gender = 'M';
    String className = 'Grade 10A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
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
                            child: const Icon(LucideIcons.userPlus, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text('បន្ថែមសិស្សថ្មី', style: AppTypography.titleMedium),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name Khmer Field
                  Text('ឈ្មោះជាភាសាខ្មែរ', style: AppTypography.captionBold),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameKhmerCtrl,
                    decoration: InputDecoration(
                      hintText: 'ឧ. សុខ សំណាង',
                      filled: true,
                      fillColor: AppColors.slateBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Full Name English
                  Text('ឈ្មោះជាឡាតាំង (English)', style: AppTypography.captionBold),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Sok Samnang',
                      filled: true,
                      fillColor: AppColors.slateBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Class & Roll Number
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ថ្នាក់រៀន', style: AppTypography.captionBold),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.slateBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: className,
                                  isExpanded: true,
                                  items: ['Grade 10A', 'Grade 12A']
                                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTypography.bodySmall)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => className = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('លេខរៀង', style: AppTypography.captionBold),
                            const SizedBox(height: 6),
                            TextField(
                              controller: rollCtrl,
                              decoration: InputDecoration(
                                hintText: '01',
                                filled: true,
                                fillColor: AppColors.slateBg,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Gender Selection
                  Text('ភេទ', style: AppTypography.captionBold),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text('ប្រុស (M)', style: AppTypography.captionBold),
                        selected: gender == 'M',
                        selectedColor: AppColors.primaryLight,
                        onSelected: (val) {
                          if (val) setModalState(() => gender = 'M');
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('ស្រី (F)', style: AppTypography.captionBold),
                        selected: gender == 'F',
                        selectedColor: const Color(0xFFFDF2F8),
                        onSelected: (val) {
                          if (val) setModalState(() => gender = 'F');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Phone Field
                  Text('លេខទូរស័ព្ទ', style: AppTypography.captionBold),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '012 345 678',
                      filled: true,
                      fillColor: AppColors.slateBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameKhmerCtrl.text.trim().isEmpty) return;
                        final newStudent = {
                          'student_id': 'STU00${_students.length + 1}',
                          'full_name': nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : nameKhmerCtrl.text.trim(),
                          'nameKhmer': nameKhmerCtrl.text.trim(),
                          'roll_number': rollCtrl.text.trim(),
                          'gender': gender,
                          'phone_number': phoneCtrl.text.trim(),
                          'class_name': className,
                        };
                        setState(() {
                          _students.insert(0, newStudent);
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('បានបន្ថែមសិស្ស ${nameKhmerCtrl.text} ជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                            backgroundColor: AppColors.successDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('រក្សាទុកសិស្ស', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStudents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('បញ្ជីសិស្ស', style: AppTypography.titleMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            tooltip: 'បន្ថែមសិស្សថ្មី',
            onPressed: _openAddStudentModal,
            icon: const Icon(LucideIcons.userPlus, size: 20, color: AppColors.primary),
          ),
          IconButton(
            tooltip: 'ផ្ទុកឡើងវិញ',
            onPressed: () async {
              await _loadStudents();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('បានផ្ទុកបញ្ជីសិស្សឡើងវិញជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
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
      body: Column(
        children: [
          // 1. Search Bar & Class Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSubtle),
                    hintText: 'ស្វែងរកតាមឈ្មោះ អត្តលេខ ឬលេខទូរស័ព្ទ...',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                    filled: true,
                    fillColor: AppColors.slateBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip('ទាំងអស់', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Grade 10A', 'Grade 10A'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Grade 12A', 'Grade 12A'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryBorder),
                      ),
                      child: Text(
                        '${filtered.length} នាក់',
                        style: AppTypography.captionBold.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Student List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.userX, size: 42, color: AppColors.textSubtle),
                            const SizedBox(height: 10),
                            Text('មិនមានសិស្សត្រូវនឹងការស្វែងរកទេ', style: AppTypography.bodyMedium),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, index) {
                          final student = filtered[index];
                          final nameKhmer = student['nameKhmer'] ?? student['full_name'] ?? 'សិស្ស';
                          final fullName = student['full_name'] ?? '';
                          final gender = student['gender'] ?? 'M';
                          final isFemale = gender == 'F';
                          final rollNumber = student['roll_number'] ?? '${index + 1}'.padLeft(2, '0');
                          final studentId = student['student_id'] ?? 'STU00$index';
                          final phone = student['phone_number']?.toString();

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
                                onTap: () => _showStudentDetailModal(student),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: isFemale ? const Color(0xFFEC4899) : AppColors.primary,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      // Avatar with initial
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: isFemale
                                            ? const Color(0xFFFDF2F8)
                                            : AppColors.primaryLight,
                                        child: Text(
                                          nameKhmer.isNotEmpty ? nameKhmer.substring(0, 1) : 'S',
                                          style: AppTypography.titleSmall.copyWith(
                                            color: isFemale
                                                ? const Color(0xFFDB2777)
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Student Information
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    nameKhmer,
                                                    style: AppTypography.titleSmall,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.slateBg,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: AppColors.border),
                                                  ),
                                                  child: Text(
                                                    '#$rollNumber',
                                                    style: AppTypography.captionBold.copyWith(
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    fullName,
                                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const Text(' • ', style: TextStyle(color: AppColors.border)),
                                                Text(
                                                  'ID: $studentId',
                                                  style: AppTypography.captionBold.copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Phone number badge (Clickable dialer)
                                      if (phone != null && phone.isNotEmpty)
                                        InkWell(
                                          onTap: () => _callPhone(phone, nameKhmer),
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(LucideIcons.phone, size: 12, color: AppColors.primary),
                                                const SizedBox(width: 5),
                                                Text(
                                                  phone,
                                                  style: AppTypography.captionBold.copyWith(color: AppColors.textPrimary),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 6),
                                      const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSubtle),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedClass == value;
    return InkWell(
      onTap: () => setState(() => _selectedClass = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? AppColors.cardShadow : null,
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
}
