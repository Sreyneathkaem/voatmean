import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/utils/validators.dart';
import 'package:voatmean_mobile/core/widgets/custom_button.dart';
import 'package:voatmean_mobile/core/widgets/custom_text_field.dart';
import '../../data/models/admin_models.dart';

/// Modal 1: Create Class Modal
class CreateClassBottomSheet extends StatefulWidget {
  final List<TeacherModel> teachers;
  final Function(ClassItem) onCreated;

  const CreateClassBottomSheet({
    super.key,
    required this.teachers,
    required this.onCreated,
  });

  @override
  State<CreateClassBottomSheet> createState() => _CreateClassBottomSheetState();
}

class _CreateClassBottomSheetState extends State<CreateClassBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  final _subjectController = TextEditingController();

  String _academicYear = '2026–2027';
  late String _selectedTeacherId;
  int _hoursPerWeek = 4;

  @override
  void initState() {
    super.initState();
    _selectedTeacherId =
    widget.teachers.isNotEmpty ? widget.teachers.first.id : '';
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final teacher = widget.teachers.firstWhere(
          (t) => t.id == _selectedTeacherId,
      orElse: () => widget.teachers.first,
    );

    final newClass = ClassItem(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      grade: _gradeController.text.trim(),
      gradeKhmer: _gradeController.text.trim().replaceAll('Grade ', 'ថ្នាក់ '),
      subject: _subjectController.text.trim(),
      subjectKhmer: _subjectController.text.trim(),
      academicYear: _academicYear,
      assignedTeacherId: teacher.id,
      assignedTeacherName: teacher.name,
      assignedTeacherKhmer: teacher.nameKhmer,
      hoursPerWeek: _hoursPerWeek,
      totalStudents: 36,
    );

    widget.onCreated(newClass);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
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
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.graduationCap, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('បង្កើតថ្នាក់ថ្មី', style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('បន្ថែមព័ត៌មានថ្នាក់រៀន និងមុខវិជ្ជាថ្មី', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, size: 20)),
                ],
              ),
              const SizedBox(height: 20),

              _buildLabel('ឆ្នាំសិក្សា (Academic Year)'),
              _buildDropdown(
                value: _academicYear,
                items: ['2026–2027', '2025–2026', '2024–2025'],
                onChanged: (v) => setState(() => _academicYear = v!),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _gradeController,
                labelText: 'កម្រិតថ្នាក់ (Grade/Class) *',
                hintText: 'e.g. Grade 10A ឬ ថ្នាក់ ១០ ក',
                validator: (val) => val == null || val.trim().isEmpty ? 'សូមបញ្ចូលឈ្មោះកម្រិតថ្នាក់' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _subjectController,
                labelText: 'មុខវិជ្ជា (Subject) *',
                hintText: 'e.g. គណិតវិទ្យា (Mathematics)',
                validator: (val) => val == null || val.trim().isEmpty ? 'សូមបញ្ចូលឈ្មោះមុខវិជ្ជា' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('ជ្រើសរើសគ្រូបង្រៀន (Select Teacher)'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTeacherId,
                    isExpanded: true,
                    items: widget.teachers.map((t) {
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text(
                          '${t.nameKhmer} (${t.name}) - ${t.subjectKhmer}',
                          style: GoogleFonts.kantumruyPro(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedTeacherId = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('ម៉ោងបង្រៀនក្នុងមួយសប្តាហ៍ (Hours/week)'),
              Row(
                children: [
                  IconButton(
                    onPressed: () { if (_hoursPerWeek > 1) setState(() => _hoursPerWeek--); },
                    icon: const Icon(LucideIcons.minusCircle),
                    color: AppColors.primary,
                  ),
                  Text('$_hoursPerWeek ម៉ោង', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () { if (_hoursPerWeek < 40) setState(() => _hoursPerWeek++); },
                    icon: const Icon(LucideIcons.plusCircle),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'បោះបង់ (Cancel)',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'រក្សាទុក (Save)',
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSubtle),
      filled: true,
      fillColor: AppColors.inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
    );
  }
}

/// Modal 2: Assign Teacher Bottom Sheet
class AssignTeacherBottomSheet extends StatefulWidget {
  final ClassItem targetClass;
  final List<TeacherModel> teachers;
  final Function(ClassItem) onUpdated;

  const AssignTeacherBottomSheet({
    super.key,
    required this.targetClass,
    required this.teachers,
    required this.onUpdated,
  });

  @override
  State<AssignTeacherBottomSheet> createState() =>
      _AssignTeacherBottomSheetState();
}

class _AssignTeacherBottomSheetState extends State<AssignTeacherBottomSheet> {
  late String _selectedTeacherId;
  late TextEditingController _subjectController;
  late TextEditingController _academicYearController;
  late int _hoursPerWeek;

  @override
  void initState() {
    super.initState();
    _selectedTeacherId = widget.targetClass.assignedTeacherId;
    _subjectController =
        TextEditingController(text: widget.targetClass.subject);
    _academicYearController =
        TextEditingController(text: widget.targetClass.academicYear);
    _hoursPerWeek = widget.targetClass.hoursPerWeek;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  void _save() {
    final teacher = widget.teachers.firstWhere(
          (t) => t.id == _selectedTeacherId,
      orElse: () => widget.teachers.first,
    );

    final updated = widget.targetClass.copyWith(
      subject: _subjectController.text.trim(),
      academicYear: _academicYearController.text.trim(),
      assignedTeacherId: teacher.id,
      assignedTeacherName: teacher.name,
      assignedTeacherKhmer: teacher.nameKhmer,
      hoursPerWeek: _hoursPerWeek,
    );

    widget.onUpdated(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
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
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.graduationCap, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ចាត់តាំងមុខវិជ្ជា និងគ្រូ', style: GoogleFonts.kantumruyPro(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('សម្រាប់ថ្នាក់៖ ${widget.targetClass.grade}', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, size: 20)),
              ],
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _academicYearController,
              labelText: 'ឆ្នាំសិក្សា (Academic Year)',
              hintText: '2026-2027',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _subjectController,
              labelText: 'មុខវិជ្ជា (Subject)',
              hintText: 'Mathematics',
            ),
            const SizedBox(height: 16),

            _buildLabel('ជ្រើសរើសគ្រូបង្រៀន (Select Teacher)'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTeacherId,
                  isExpanded: true,
                  items: widget.teachers.map((t) {
                    return DropdownMenuItem(
                      value: t.id,
                      child: Text(
                        '${t.nameKhmer} (${t.name}) - ${t.subjectKhmer}',
                        style: GoogleFonts.kantumruyPro(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedTeacherId = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('ម៉ោងបង្រៀនក្នុងមួយសប្តាហ៍ (Hours/week)'),
            Row(
              children: [
                IconButton(
                  onPressed: () { if (_hoursPerWeek > 1) setState(() => _hoursPerWeek--); },
                  icon: const Icon(LucideIcons.minusCircle),
                  color: AppColors.primary,
                ),
                Text('$_hoursPerWeek ម៉ោង', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () { if (_hoursPerWeek < 40) setState(() => _hoursPerWeek++); },
                  icon: const Icon(LucideIcons.plusCircle),
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'បោះបង់ (Cancel)',
                    onPressed: () => Navigator.pop(context),
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'រក្សាទុក (Save)',
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Modal 3: Add Teacher Bottom Sheet
class AddTeacherBottomSheet extends StatefulWidget {
  final List<ClassItem> classes;
  final Function(TeacherModel) onAdded;

  const AddTeacherBottomSheet({
    super.key,
    required this.classes,
    required this.onAdded,
  });

  @override
  State<AddTeacherBottomSheet> createState() => _AddTeacherBottomSheetState();
}

class _AddTeacherBottomSheetState extends State<AddTeacherBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameKhmerCtrl = TextEditingController();
  final _nameLatinCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _gender = 'M';
  String _subject = 'Mathematics';
  String _subjectKhmer = 'គណិតវិទ្យា';
  String _assignedClass = '';
  bool _isLoading = false;

  bool get _isDirty =>
      _nameKhmerCtrl.text.isNotEmpty ||
          _nameLatinCtrl.text.isNotEmpty ||
          _phoneCtrl.text.isNotEmpty ||
          _emailCtrl.text.isNotEmpty;

  void _handleCancel() {
    if (_isDirty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                child: const Icon(LucideIcons.alertCircle, color: Color(0xFFEA580C)),
              ),
              const SizedBox(height: 16),
              Text('បោះបង់ការបន្ថែមគ្រូ?', style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('ទិន្នន័យដែលអ្នកបានបំពេញនឹងត្រូវបាត់បង់ ប្រសិនបើអ្នកបោះបង់។', textAlign: TextAlign.center, style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'កែសម្រួលបន្ត',
                      onPressed: () => Navigator.pop(ctx),
                      isOutlined: true,
                      backgroundColor: Colors.white,
                      textColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      text: 'បោះបង់',
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      backgroundColor: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final newTeacher = TeacherModel(
      id: 'tch-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameLatinCtrl.text.trim().isNotEmpty
          ? _nameLatinCtrl.text.trim()
          : _nameKhmerCtrl.text.trim(),
      nameKhmer: _nameKhmerCtrl.text.trim(),
      gender: _gender,
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      subject: _subject,
      subjectKhmer: _subjectKhmer,
      assignedClasses: _assignedClass.isNotEmpty ? [_assignedClass] : [],
      teachingHoursPerWeek: 20,
      avatarUrl: _gender == 'F'
          ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKXn-M7jF75SMdrp_hGjewG7ANg6848MJ5nrOG_44YRFPaWD40XYQEjgp4g7PfJRXS1bs-O6q0jLQZt7xim1XJrHg_A03d7vQJ-C0CgG-f-pH1Cs6A5zPbrcJQODahwb0Cbqhsz3VjyLDqSSLW43iS-rwkuYmX4ODnTPXLT6wA4a4TcGP61Ka7QtTlJNJghMNGVTpZ1RhT_w7fmn1DZOyhL_XxomSk3GnTJDWUOSZNU4hFLXeR7xc'
          : 'https://lh3.googleusercontent.com/aida-public/AB6AXuBW60befM5ZEuh3cxe1G0lFhJPxhypregWJHKo1-hfuMx2Nz3QkzlB8NeWkXkCk5BQl_PRTXh7PPqYrIg5drnobS_azzQ1KBedpg20vJWfNGNC4vk5_7F8I7Q8bkuWLBti5jbTOUK396MJMdlrBX-yE2a87Sqt5Ki9PuayDZHI35cIW-aeXzcHeERXz1oJ_7ZxU4WqN9usU742nu8iXkUIrJV5DQJkQUN5eeqfpUh-CCPVL1daNeU',
    );

    widget.onAdded(newTeacher);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 48, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.userPlus, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('បន្ថែមគ្រូបង្រៀន', style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('បំពេញព័ត៌មានដើម្បីបង្កើតគណនីគ្រូថ្មី', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(onPressed: _handleCancel, icon: const Icon(LucideIcons.x, size: 20)),
                ],
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _nameKhmerCtrl,
                labelText: 'ឈ្មោះពេញ (ភាសាខ្មែរ) *',
                hintText: 'ឧទាហរណ៍៖ សុខ សំណាង',
                validator: (v) => Validators.required(v, 'ឈ្មោះជាភាសាខ្មែរ'),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameLatinCtrl,
                labelText: 'ឈ្មោះពេញ (Latin / English)',
                hintText: 'e.g. Sok Samnang',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('ភេទ (Gender) *'),
                        _buildDropdown(
                          value: _gender,
                          items: const [DropdownMenuItem(value: 'M', child: Text('ប្រុស (Male)')), DropdownMenuItem(value: 'F', child: Text('ស្រី (Female)'))],
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('មុខវិជ្ជាឯកទេស'),
                        _buildDropdown(
                          value: _subject,
                          items: const [
                            DropdownMenuItem(value: 'Mathematics', child: Text('គណិតវិទ្យា')),
                            DropdownMenuItem(value: 'Physics', child: Text('រូបវិទ្យា')),
                            DropdownMenuItem(value: 'Chemistry', child: Text('គីមីវិទ្យា')),
                            DropdownMenuItem(value: 'English Literature', child: Text('ភាសាអង់គ្លេស')),
                            DropdownMenuItem(value: 'Khmer Literature', child: Text('ភាសាខ្មែរ')),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _subject = v!;
                              if (v == 'Mathematics') _subjectKhmer = 'គណិតវិទ្យា';
                              else if (v == 'Physics') _subjectKhmer = 'រូបវិទ្យា';
                              else if (v == 'Chemistry') _subjectKhmer = 'គីមីវិទ្យា';
                              else if (v == 'English Literature') _subjectKhmer = 'ភាសាអង់ក្លេស';
                              else if (v == 'Khmer Literature') _subjectKhmer = 'ភាសាខ្មែរ';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneCtrl,
                labelText: 'លេខទូរស័ព្ទ (Telephone) *',
                hintText: '012 345 678',
                keyboardType: TextInputType.phone,
                validator: (v) => Validators.required(v, 'លេខទូរស័ព្ទ'),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailCtrl,
                labelText: 'អុីមែល (Email) *',
                hintText: 'teacher@school.edu',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),

              _buildLabel('បន្ទុកថ្នាក់ (Assigned Class) - ស្រេចចិត្ត'),
              _buildDropdown(
                value: _assignedClass,
                items: [
                  const DropdownMenuItem(value: '', child: Text('-- មិនទាន់កំណត់ថ្នាក់ --')),
                  ...widget.classes.map((c) => DropdownMenuItem(value: c.grade, child: Text('${c.grade} (${c.gradeKhmer})'))),
                ],
                onChanged: (v) => setState(() => _assignedClass = v!),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: CustomButton(text: 'បោះបង់ (Cancel)', onPressed: _handleCancel, isOutlined: true)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: CustomButton(text: '+ បន្ថែមគ្រូ', onPressed: _submit, isLoading: _isLoading)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildDropdown({required dynamic value, required List<DropdownMenuItem<dynamic>> items, required ValueChanged<dynamic?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Modal 4: Edit Teacher Modal
class EditTeacherModal extends StatefulWidget {
  final TeacherModel teacher;
  final List<ClassItem> classes;
  final Function(TeacherModel) onUpdated;

  const EditTeacherModal({
    super.key,
    required this.teacher,
    required this.classes,
    required this.onUpdated,
  });

  @override
  State<EditTeacherModal> createState() => _EditTeacherModalState();
}

class _EditTeacherModalState extends State<EditTeacherModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameKhmerCtrl;
  late TextEditingController _nameLatinCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late String _gender;
  late String _subject;
  late String _subjectKhmer;
  late int _teachingHours;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameKhmerCtrl = TextEditingController(text: widget.teacher.nameKhmer);
    _nameLatinCtrl = TextEditingController(text: widget.teacher.name);
    _phoneCtrl = TextEditingController(text: widget.teacher.phone);
    _emailCtrl = TextEditingController(text: widget.teacher.email);
    _gender = widget.teacher.gender;
    _subject = widget.teacher.subject;
    _subjectKhmer = widget.teacher.subjectKhmer;
    _teachingHours = widget.teacher.teachingHoursPerWeek;
  }

  @override
  void dispose() {
    _nameKhmerCtrl.dispose();
    _nameLatinCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    widget.onUpdated(
      widget.teacher.copyWith(
        nameKhmer: _nameKhmerCtrl.text.trim(),
        name: _nameLatinCtrl.text.trim().isNotEmpty
            ? _nameLatinCtrl.text.trim()
            : _nameKhmerCtrl.text.trim(),
        gender: _gender,
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        subject: _subject,
        subjectKhmer: _subjectKhmer,
        teachingHoursPerWeek: _teachingHours,
      ),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 48, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.edit, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('កែប្រែព័ត៌មានគ្រូបង្រៀន', style: GoogleFonts.kantumruyPro(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(widget.teacher.nameKhmer, style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, size: 20)),
                ],
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _nameKhmerCtrl,
                labelText: 'ឈ្មោះពេញ (ភាសាខ្មែរ) *',
                hintText: 'ឧទាហរណ៍៖ សុខ សំណាង',
                validator: (v) => Validators.required(v, 'ឈ្មោះជាភាសាខ្មែរ'),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameLatinCtrl,
                labelText: 'ឈ្មោះពេញ (Latin / English)',
                hintText: 'e.g. Sok Samnang',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('ភេទ (Gender)'),
                        _buildDropdown(
                          value: _gender,
                          items: const [DropdownMenuItem(value: 'M', child: Text('ប្រុស (Male)')), DropdownMenuItem(value: 'F', child: Text('ស្រី (Female)'))],
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('មុខវិជ្ជា'),
                        _buildDropdown(
                          value: _subject,
                          items: const [
                            DropdownMenuItem(value: 'Mathematics', child: Text('គណិតវិទ្យា')),
                            DropdownMenuItem(value: 'Physics', child: Text('រូបវិទ្យា')),
                            DropdownMenuItem(value: 'Chemistry', child: Text('គីមីវិទ្យា')),
                            DropdownMenuItem(value: 'English Literature', child: Text('ភាសាអង់គ្លេស')),
                            DropdownMenuItem(value: 'Khmer Literature', child: Text('ភាសាខ្មែរ')),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _subject = v!;
                              if (v == 'Mathematics') _subjectKhmer = 'គណិតវិទ្យា';
                              else if (v == 'Physics') _subjectKhmer = 'រូបវិទ្យា';
                              else if (v == 'Chemistry') _subjectKhmer = 'គីមីវិទ្យា';
                              else if (v == 'English Literature') _subjectKhmer = 'ភាសាអង់ក្លេស';
                              else if (v == 'Khmer Literature') _subjectKhmer = 'ភាសាខ្មែរ';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneCtrl,
                labelText: 'លេខទូរស័ព្ទ (Telephone) *',
                hintText: '012 345 678',
                keyboardType: TextInputType.phone,
                validator: (v) => Validators.required(v, 'លេខទូរស័ព្ទ'),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailCtrl,
                labelText: 'អុីមែល (Email) *',
                hintText: 'teacher@school.edu',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),

              _buildLabel('ម៉ោងបង្រៀនក្នុងមួយសប្តាហ៍'),
              Row(
                children: [
                  IconButton(onPressed: () { if (_teachingHours > 1) setState(() => _teachingHours--); }, icon: const Icon(LucideIcons.minusCircle), color: AppColors.primary),
                  Text('$_teachingHours ម៉ោង/សប្តាហ៍', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () { if (_teachingHours < 40) setState(() => _teachingHours++); }, icon: const Icon(LucideIcons.plusCircle), color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: CustomButton(text: 'បោះបង់ (Cancel)', onPressed: () => Navigator.pop(context), isOutlined: true)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: CustomButton(text: 'រក្សាទុកការកែប្រែ', onPressed: _submit, isLoading: _isLoading)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildDropdown({required dynamic value, required List<DropdownMenuItem<dynamic>> items, required ValueChanged<dynamic?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
