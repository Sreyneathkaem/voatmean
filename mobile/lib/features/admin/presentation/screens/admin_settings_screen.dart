import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import '../../data/services/admin_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  final VoidCallback onSignOut;
  final VoidCallback onSwitchToTeacherPortal;

  const AdminSettingsScreen({
    super.key,
    required this.onSignOut,
    required this.onSwitchToTeacherPortal,
  });

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  String _adminName = 'គណៈគ្រប់គ្រងសាលា';
  String _schoolName = 'វិទ្យាល័យ ហ៊ុន សែន • រាជធានីភ្នំពេញ';
  String _adminEmail = 'admin@voatmean.edu.kh';
  String _adminPhone = '012 888 777';

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.logOut, color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 12),
            Text('ចាកចេញពីកម្មវិធី', style: AppTypography.titleMedium),
          ],
        ),
        content: Text(
          'តើលោកអ្នកពិតជាចង់ចាកចេញពីគណនីអ្នកគ្រប់គ្រងមែនទេ?',
          style: AppTypography.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text('ចាកចេញ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showScoreFormulaModal() async {
    final adminService = AdminService();
    final config = await adminService.getDefaultScoreFormula();
    double attendanceWeight = 0.30;
    double teacherScoreWeight = 0.70;
    String mode = 'weighted_blend';

    if (config != null) {
      attendanceWeight = (config['attendance_weight'] as num?)?.toDouble() ?? 0.30;
      teacherScoreWeight = (config['teacher_score_weight'] as num?)?.toDouble() ?? 0.70;
      mode = config['mode']?.toString() ?? 'weighted_blend';
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.calculator, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('រូបមន្តគណនាពិន្ទុ (Score Formula)', style: AppTypography.titleMedium),
                        Text('កំណត់សមាមាត្រពិន្ទុវត្តមាន និងពិន្ទុគ្រូដាក់', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slateBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ពិន្ទុវត្តមាន (Attendance)', style: AppTypography.labelMedium),
                        Text('${(attendanceWeight * 100).round()}%',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: attendanceWeight,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      activeColor: AppColors.primary,
                      onChanged: (v) {
                        setModalState(() {
                          attendanceWeight = double.parse(v.toStringAsFixed(2));
                          teacherScoreWeight = double.parse((1.0 - attendanceWeight).toStringAsFixed(2));
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ពិន្ទុគ្រូដាក់ (Teacher Score)', style: AppTypography.labelMedium),
                        Text('${(teacherScoreWeight * 100).round()}%',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.warningDark, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: teacherScoreWeight,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      activeColor: AppColors.warningDark,
                      onChanged: (v) {
                        setModalState(() {
                          teacherScoreWeight = double.parse(v.toStringAsFixed(2));
                          attendanceWeight = double.parse((1.0 - teacherScoreWeight).toStringAsFixed(2));
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final ok = await adminService.updateDefaultScoreFormula(
                      mode: mode,
                      attendanceWeight: attendanceWeight,
                      teacherScoreWeight: teacherScoreWeight,
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? 'បានរក្សាទុករូបមន្តពិន្ទុដោយជោគជ័យ' : 'បរាជ័យក្នុងការរក្សាទុករូបមន្ត',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white),
                        ),
                        backgroundColor: ok ? AppColors.primary : AppColors.danger,
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
                  child: Text('រក្សាទុកការកំណត់', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManageSubjectsModal() async {
    final adminService = AdminService();
    List<Map<String, dynamic>> subjects = await adminService.getSubjects();
    final newSubjectCtrl = TextEditingController();
    bool isCreating = false;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
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
                        child: const Icon(LucideIcons.bookOpen, size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text('គ្រប់គ្រងមុខវិជ្ជាសិក្សា', style: AppTypography.titleMedium),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'មុខវិជ្ជាចំណេះទូទៅ និងអនុវិទ្យាល័យ/វិទ្យាល័យ (សរុប ${subjects.length} មុខវិជ្ជា)',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Add New Subject Input Row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.slateBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newSubjectCtrl,
                        decoration: InputDecoration(
                          hintText: 'បញ្ចូលឈ្មោះមុខវិជ្ជាថ្មី (ឧ. សេដ្ឋកិច្ចវិទ្យា)...',
                          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isCreating
                          ? null
                          : () async {
                              final name = newSubjectCtrl.text.trim();
                              if (name.isEmpty) return;
                              setModalState(() => isCreating = true);
                              final success = await adminService.createSubject(name);
                              if (success) {
                                newSubjectCtrl.clear();
                                final updated = await adminService.getSubjects();
                                setModalState(() {
                                  subjects = updated;
                                  isCreating = false;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('បានបង្កើតមុខវិជ្ជា "$name" ដោយជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else {
                                setModalState(() => isCreating = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('បរាជ័យក្នុងការបង្កើត ឬមុខវិជ្ជាមានរួចហើយ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                                      backgroundColor: AppColors.danger,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: isCreating
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(LucideIcons.plus, size: 16),
                      label: Text('បន្ថែម', style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Existing Subjects List
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: subjects.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('មិនទាន់មានមុខវិជ្ជាទេ', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: subjects.length,
                        separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (ctx, idx) {
                          final s = subjects[idx];
                          final sName = s['subject_name']?.toString() ?? 'មុខវិជ្ជា';
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: AppTypography.captionBold.copyWith(color: AppColors.primary),
                                ),
                              ),
                            ),
                            title: Text(sName, style: AppTypography.bodyMedium),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.successBorder),
                              ),
                              child: Text(
                                'សកម្ម',
                                style: AppTypography.captionBold.copyWith(color: AppColors.successText, fontSize: 11),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _adminName);
    final schoolCtrl = TextEditingController(text: _schoolName);
    final emailCtrl = TextEditingController(text: _adminEmail);
    final phoneCtrl = TextEditingController(text: _adminPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                  Text('ព័ត៌មានផ្ទាល់ខ្លួន Admin', style: AppTypography.titleLarge),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('ឈ្មោះគណនី', style: AppTypography.labelSmall),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slateBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 12),

              Text('ឈ្មោះសាលារៀន', style: AppTypography.labelSmall),
              const SizedBox(height: 6),
              TextField(
                controller: schoolCtrl,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slateBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 12),

              Text('អ៊ីមែល', style: AppTypography.labelSmall),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slateBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 12),

              Text('លេខទូរស័ព្ទទំនាក់ទំនង', style: AppTypography.labelSmall),
              const SizedBox(height: 6),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slateBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _adminName = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : _adminName;
                      _schoolName = schoolCtrl.text.trim().isNotEmpty ? schoolCtrl.text.trim() : _schoolName;
                      _adminEmail = emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : _adminEmail;
                      _adminPhone = phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : _adminPhone;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('បានកែសម្រួលព័ត៌មានដោយជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
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
                  child: Text('រក្សាទុកការកែប្រែ', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordModal() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;

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
                    Text('ប្តូរពាក្យសម្ងាត់', style: AppTypography.titleLarge),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('ពាក្យសម្ងាត់បច្ចុប្បន្ន *', style: AppTypography.labelSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: currentPassCtrl,
                  obscureText: obscureCurrent,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'បញ្ចូលពាក្យសម្ងាត់ចាស់',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                    filled: true,
                    fillColor: AppColors.slateBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                      onPressed: () => setModalState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text('ពាក្យសម្ងាត់ថ្មី *', style: AppTypography.labelSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: newPassCtrl,
                  obscureText: obscureNew,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'យ៉ាងតិច ៦ តួអក្សរ',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                    filled: true,
                    fillColor: AppColors.slateBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                      onPressed: () => setModalState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text('បញ្ជាក់ពាក្យសម្ងាត់ថ្មី *', style: AppTypography.labelSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: obscureNew,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'បញ្ចូលពាក្យសម្ងាត់ថ្មីម្តងទៀត',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                    filled: true,
                    fillColor: AppColors.slateBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) {
                        return;
                      }
                      if (newPassCtrl.text != confirmPassCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ពាក្យសម្ងាត់ផ្ទៀងផ្ទាត់មិនត្រូវគ្នាទេ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('បានប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
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
                    child: Text('ប្តូរពាក្យសម្ងាត់', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ការកំណត់', style: AppTypography.titleMedium),
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
          // 1. Admin Profile Card
          _buildProfileCard(),
          const SizedBox(height: 20),

          // 2. Account & Security
          _buildSectionTitle('គណនី និងសុវត្ថិភាព'),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.user, size: 18, color: AppColors.primary),
              ),
              title: Text('ព័ត៌មានផ្ទាល់ខ្លួន', style: AppTypography.labelMedium),
              subtitle: Text('កែសម្រួលឈ្មោះ អ៊ីមែល និងសាលារៀន', style: AppTypography.caption),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSubtle),
              onTap: _showEditProfileModal,
            ),
            const Divider(height: 1, indent: 56, color: AppColors.border),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.lock, size: 18, color: AppColors.textSecondary),
              ),
              title: Text('ប្តូរពាក្យសម្ងាត់', style: AppTypography.labelMedium),
              subtitle: Text('ផ្លាស់ប្តូរលេខកូដសម្ងាត់គណនី', style: AppTypography.caption),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSubtle),
              onTap: _showChangePasswordModal,
            ),
          ]),
          const SizedBox(height: 20),

          // 3. Application Settings
          _buildSectionTitle('ការកំណត់កម្មវិធី'),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.bell, size: 18, color: AppColors.primary),
              ),
              title: Text('ការជូនដំណឹង', style: AppTypography.labelMedium),
              subtitle: Text('ទទួលដំណឹងពីការស្រង់វត្តមានរបស់គ្រូ', style: AppTypography.caption),
              value: _notificationsEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v ? 'បានបើកការជូនដំណឹង' : 'បានបិទការជូនដំណឹង',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            const Divider(height: 1, indent: 56, color: AppColors.border),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.moon, size: 18, color: AppColors.textSecondary),
              ),
              title: Text('មុខងារងងឹត (Dark Mode)', style: AppTypography.labelMedium),
              subtitle: Text('ប្តូរផ្ទៃកម្មវិធីជាពណ៌ងងឹត', style: AppTypography.caption),
              value: _darkMode,
              activeTrackColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _darkMode = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v ? 'មុខងារងងឹតកំពុងរៀបចំ' : 'បានប្តូរទៅកាន់មុខងារពន្លឺ',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            const Divider(height: 1, indent: 56, color: AppColors.border),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.calculator, size: 18, color: AppColors.primary),
              ),
              title: Text('រូបមន្តគណនាពិន្ទុ (Score Formula)', style: AppTypography.labelMedium),
              subtitle: Text('កំណត់ទម្ងន់ពិន្ទុវត្តមាន និងពិន្ទុគ្រូដាក់', style: AppTypography.caption),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSubtle),
              onTap: _showScoreFormulaModal,
            ),
            const Divider(height: 1, indent: 56, color: AppColors.border),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.bookOpen, size: 18, color: AppColors.primary),
              ),
              title: Text('គ្រប់គ្រងមុខវិជ្ជា (Manage Subjects)', style: AppTypography.labelMedium),
              subtitle: Text('មើលបញ្ជីមុខវិជ្ជា និងបង្កើតមុខវិជ្ជាបន្ថែម', style: AppTypography.caption),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSubtle),
              onTap: _showManageSubjectsModal,
            ),
          ]),
          const SizedBox(height: 20),

          // 4. Actions
          _buildSectionTitle('សកម្មភាព'),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.refreshCw, size: 18, color: AppColors.primary),
              ),
              title: Text(
                'ប្តូរទៅកាន់ Teacher Portal',
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              ),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.primary),
              onTap: widget.onSwitchToTeacherPortal,
            ),
            const Divider(height: 1, indent: 56, color: AppColors.border),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.logOut, size: 18, color: AppColors.danger),
              ),
              title: Text(
                'ចាកចេញពីកម្មវិធី',
                style: AppTypography.labelMedium.copyWith(color: AppColors.danger),
              ),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.danger),
              onTap: _confirmSignOut,
            ),
          ]),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Voatmean School Management • v1.0.0',
              style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
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
              child: Container(color: AppColors.primary),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showEditProfileModal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 16, top: 16, bottom: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.blueBg,
                        child: Text(
                          _adminName.isNotEmpty ? _adminName.substring(0, 1) : 'អ',
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
                                  child: Text(
                                    _adminName,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.blueBorder),
                                  ),
                                  child: Text(
                                    'Admin',
                                    style: AppTypography.captionBold.copyWith(color: AppColors.blueText),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _schoolName,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_adminEmail • $_adminPhone',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.edit3, size: 18, color: AppColors.primary),
                        onPressed: _showEditProfileModal,
                        tooltip: 'កែសម្រួល',
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
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}
