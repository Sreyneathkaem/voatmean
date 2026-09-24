import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import '../../data/models/admin_models.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<StudentModel> _students = [
    StudentModel(
      id: '1',
      studentId: 'STU001',
      name: 'Chan Sreymom',
      nameKhmer: 'ចាន់ ស្រីមុំ',
      gender: 'F',
      phone: '012 111 222',
      currentClass: 'Grade 10A',
      guardianPhone: '012 333 444',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
    ),
    StudentModel(
      id: '2',
      studentId: 'STU002',
      name: 'Heng Piseth',
      nameKhmer: 'ហេង ពិសិដ្ឋ',
      gender: 'M',
      phone: '012 555 666',
      currentClass: 'Grade 10A',
      guardianPhone: '012 777 888',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
    ),
    StudentModel(
      id: '3',
      studentId: 'STU003',
      name: 'Sok Samnang',
      nameKhmer: 'សុខ សំណាង',
      gender: 'M',
      phone: '012 345 678',
      currentClass: 'Grade 10A',
      guardianPhone: '012 888 999',
      avatarUrl: 'https://i.pravatar.cc/150?u=3',
    ),
    StudentModel(
      id: '4',
      studentId: 'STU004',
      name: 'Keo Bopha',
      nameKhmer: 'កែវ បុប្ផា',
      gender: 'F',
      phone: '098 765 432',
      currentClass: 'Grade 12A',
      guardianPhone: '098 111 222',
      avatarUrl: 'https://i.pravatar.cc/150?u=4',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> get _filteredStudents {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return _students;
    return _students.where((s) {
      return s.nameKhmer.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q) ||
          s.studentId.toLowerCase().contains(q) ||
          s.phone.contains(q) ||
          s.currentClass.toLowerCase().contains(q);
    }).toList();
  }

  void _confirmCall(String targetName, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
            const SizedBox(width: 10),
            Text('ទូរស័ព្ទទៅកាន់', style: AppTypography.titleMedium),
          ],
        ),
        content: Text(
          'តើលោកអ្នកចង់ទូរស័ព្ទទៅកាន់ $targetName ($phone) ដែរឬទេ?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('កំពុងទូរស័ព្ទទៅកាន់ $phone...', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(LucideIcons.phone, size: 16),
            label: Text('ហៅចេញ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentModal() {
    final idCtrl = TextEditingController(text: 'STU00${_students.length + 1}');
    final khmerNameCtrl = TextEditingController();
    final latinNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final guardianCtrl = TextEditingController();
    String selectedGender = 'F';
    String selectedClass = 'Grade 10A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
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
                    Text('បន្ថែមសិស្សថ្មី', style: AppTypography.titleLarge),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Khmer Name
                Text('ឈ្មោះសិស្ស (ភាសាខ្មែរ) *', style: AppTypography.labelSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: khmerNameCtrl,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'ឧ. មុីន សុផា',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                    filled: true,
                    fillColor: AppColors.slateBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 14),

                // Latin Name & ID Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ឈ្មោះឡាតាំង *', style: AppTypography.labelSmall),
                          const SizedBox(height: 6),
                          TextField(
                            controller: latinNameCtrl,
                            style: AppTypography.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'ឧ. Min Sopha',
                              hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                              filled: true,
                              fillColor: AppColors.slateBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('អត្តលេខ *', style: AppTypography.labelSmall),
                          const SizedBox(height: 6),
                          TextField(
                            controller: idCtrl,
                            style: AppTypography.bodyMedium,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.slateBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Gender & Class
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ភេទ *', style: AppTypography.labelSmall),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('ស្រី'),
                                selected: selectedGender == 'F',
                                selectedColor: const Color(0xFFFDF2F8),
                                labelStyle: TextStyle(
                                  color: selectedGender == 'F' ? const Color(0xFFDB2777) : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (s) => setModalState(() => selectedGender = 'F'),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('ប្រុស'),
                                selected: selectedGender == 'M',
                                selectedColor: AppColors.primaryLight,
                                labelStyle: TextStyle(
                                  color: selectedGender == 'M' ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (s) => setModalState(() => selectedGender = 'M'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ថ្នាក់រៀន *', style: AppTypography.labelSmall),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.slateBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedClass,
                                isExpanded: true,
                                items: ['Grade 10A', 'Grade 10B', 'Grade 11A', 'Grade 12A'].map((c) {
                                  return DropdownMenuItem(value: c, child: Text(c, style: AppTypography.bodySmall));
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setModalState(() => selectedClass = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Phone & Guardian Phone
                Text('លេខទូរស័ព្ទសិស្ស', style: AppTypography.labelSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '012 345 678',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                    filled: true,
                    fillColor: AppColors.slateBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 14),

                Text('លេខទូរស័ព្ទអាណាព្យាបាល *', style: AppTypography.labelSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: guardianCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '098 765 432',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                    filled: true,
                    fillColor: AppColors.slateBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 22),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (khmerNameCtrl.text.trim().isEmpty) return;
                      final newStudent = StudentModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        studentId: idCtrl.text.trim().isNotEmpty ? idCtrl.text.trim() : 'STU009',
                        name: latinNameCtrl.text.trim().isNotEmpty ? latinNameCtrl.text.trim() : khmerNameCtrl.text.trim(),
                        nameKhmer: khmerNameCtrl.text.trim(),
                        gender: selectedGender,
                        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '012 000 000',
                        currentClass: selectedClass,
                        guardianPhone: guardianCtrl.text.trim().isNotEmpty ? guardianCtrl.text.trim() : '012 999 888',
                        avatarUrl: 'https://i.pravatar.cc/150?u=${DateTime.now().millisecond}',
                      );
                      setState(() {
                        _students.insert(0, newStudent);
                      });
                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('បានបន្ថែមសិស្ស ${newStudent.nameKhmer} ជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('រក្សាទុកសិស្សថ្មី', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStudentDetailModal(StudentModel student) {
    final isFemale = student.gender == 'F';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 18),

            // Profile header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isFemale ? const Color(0xFFFDF2F8) : AppColors.primaryLight,
                  child: Text(
                    student.nameKhmer.isNotEmpty ? student.nameKhmer.substring(0, 1) : 'ស',
                    style: AppTypography.displayLarge.copyWith(
                      color: isFemale ? const Color(0xFFDB2777) : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.nameKhmer, style: AppTypography.titleLarge),
                      const SizedBox(height: 2),
                      Text(student.name, style: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(student.currentClass, style: AppTypography.captionBold.copyWith(color: AppColors.primary)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slateBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text('ID: ${student.studentId}', style: AppTypography.captionBold.copyWith(color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),

            // Contact Info
            Text('ព័ត៌មានទំនាក់ទំនង', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 10),

            // Student Phone
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slateBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.smartphone, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ទូរស័ព្ទសិស្ស', style: AppTypography.caption),
                        Text(student.phone, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.phone, size: 18, color: AppColors.primary),
                    onPressed: () => _confirmCall(student.nameKhmer, student.phone),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Guardian Phone
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slateBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.users, size: 18, color: Color(0xFF059669)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ទូរស័ព្ទអាណាព្យាបាល', style: AppTypography.caption),
                        Text(student.guardianPhone, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.phone, size: 18, color: Color(0xFF059669)),
                    onPressed: () => _confirmCall('អាណាព្យាបាល ${student.nameKhmer}', student.guardianPhone),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showDialog(
                        context: context,
                        builder: (deleteCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          title: Text('លុបសិស្ស?', style: AppTypography.titleMedium),
                          content: Text('តើអ្នកប្រាកដថាចង់លុបសិស្ស ${student.nameKhmer}?', style: AppTypography.bodyMedium),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(deleteCtx),
                              child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _students.removeWhere((s) => s.id == student.id);
                                });
                                Navigator.pop(deleteCtx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('បានលុបសិស្សដោយជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
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
                    },
                    icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                    label: Text('លុបសិស្ស', style: AppTypography.labelMedium.copyWith(color: AppColors.danger)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.dangerBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('មុខងារកែប្រែសិស្ស ${student.nameKhmer} ត្រូវបានរក្សាទុក', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.edit3, size: 16),
                    label: Text('កែប្រែ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
        title: Text('គ្រប់គ្រងសិស្ស', style: AppTypography.titleMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _showAddStudentModal,
              icon: const Icon(LucideIcons.plus, size: 15),
              label: Text(
                'បន្ថែមសិស្ស',
                style: AppTypography.labelSmall.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSubtle),
                hintText: 'ស្វែងរកតាមឈ្មោះ អត្តលេខ ឬថ្នាក់...',
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
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.userX, size: 40, color: AppColors.textSubtle),
                        const SizedBox(height: 10),
                        Text('រកមិនឃើញសិស្សតាមការស្វែងរកទេ', style: AppTypography.bodyMedium),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final student = filtered[index];
                      final isFemale = student.gender == 'F';
                      final accentColor = isFemale ? const Color(0xFFEC4899) : AppColors.primary;

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
                                child: Container(color: accentColor),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showStudentDetailModal(student),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 12),
                                    child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: isFemale
                                        ? const Color(0xFFFDF2F8)
                                        : AppColors.primaryLight,
                                    child: Text(
                                      student.nameKhmer.isNotEmpty
                                          ? student.nameKhmer.substring(0, 1)
                                          : 'ស',
                                      style: AppTypography.titleSmall.copyWith(
                                        color: isFemale
                                            ? const Color(0xFFDB2777)
                                            : AppColors.primary,
                                        fontWeight: FontWeight.bold,
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
                                            Flexible(
                                              child: Text(
                                                student.nameKhmer,
                                                style: AppTypography.titleSmall.copyWith(
                                                  color: const Color(0xFF0F172A),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.primaryBorder),
                                              ),
                                              child: Text(
                                                student.currentClass,
                                                style: AppTypography.captionBold.copyWith(
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              'ID: ${student.studentId}',
                                              style: AppTypography.captionBold.copyWith(color: AppColors.textSecondary),
                                            ),
                                            const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                                            Text(
                                              student.phone,
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(LucideIcons.phone, size: 18, color: AppColors.primary),
                                    onPressed: () => _confirmCall(student.nameKhmer, student.phone),
                                    tooltip: 'ទូរស័ព្ទ',
                                  ),
                                  const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSubtle),
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
                  ),
          ),
        ],
      ),
    );
  }
}
