import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';

class TeacherSettingsScreen extends StatefulWidget {
  final VoidCallback onSignOut;
  final VoidCallback? onSwitchToAdminPortal;

  const TeacherSettingsScreen({
    super.key,
    required this.onSignOut,
    this.onSwitchToAdminPortal,
  });

  @override
  State<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends State<TeacherSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _currentLanguage = 'ភាសាខ្មែរ';
  String _teacherName = 'លោកគ្រូ សុខ សំណាង';
  String _teacherPhone = '012 345 678';
  String _teacherSubject = 'គណិតវិទ្យា';

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
          'តើលោកអ្នកពិតជាចង់ចាកចេញពីគណនីគ្រូបង្រៀនមែនទេ?',
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

  void _openEditProfileModal() {
    final nameCtrl = TextEditingController(text: _teacherName);
    final phoneCtrl = TextEditingController(text: _teacherPhone);
    final subjectCtrl = TextEditingController(text: _teacherSubject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
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
                        child: const Icon(LucideIcons.userCheck, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('កែប្រែព័ត៌មានគ្រូបង្រៀន', style: AppTypography.titleMedium),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('ឈ្មោះពេញ', style: AppTypography.captionBold),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slateBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              Text('មុខវិជ្ជាបង្រៀន', style: AppTypography.captionBold),
              const SizedBox(height: 6),
              TextField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slateBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              Text('លេខទូរស័ព្ទ', style: AppTypography.captionBold),
              const SizedBox(height: 6),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slateBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _teacherName = nameCtrl.text.trim();
                      _teacherSubject = subjectCtrl.text.trim();
                      _teacherPhone = phoneCtrl.text.trim();
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('បានកែប្រែព័ត៌មានគ្រូបង្រៀនជោគជ័យ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
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
                  child: Text('រក្សាទុកការផ្លាស់ប្តូរ', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _openLanguageModal() {
    showModalBottomSheet(
      context: context,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.globe, color: AppColors.successDark, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('ជ្រើសរើសភាសា (Language)', style: AppTypography.titleMedium),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              title: Text('ភាសាខ្មែរ (Khmer)', style: AppTypography.bodyMedium),
              trailing: _currentLanguage == 'ភាសាខ្មែរ'
                  ? const Icon(LucideIcons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _currentLanguage = 'ភាសាខ្មែរ');
                Navigator.pop(ctx);
              },
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              title: Text('English (US)', style: AppTypography.bodyMedium),
              trailing: _currentLanguage == 'English'
                  ? const Icon(LucideIcons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _currentLanguage = 'English');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _openHelpGuideModal() {
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
                      child: const Icon(LucideIcons.helpCircle, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('របៀបស្រង់វត្តមានសិស្ស', style: AppTypography.titleMedium),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGuideStep('១', 'ជ្រើសរើសថ្នាក់រៀន', 'ចុចលើថ្នាក់រៀនដែលលោកអ្នកត្រូវបង្រៀនក្នុងកាលវិភាគថ្ងៃនេះ។'),
            const SizedBox(height: 12),
            _buildGuideStep('២', 'កត់ត្រាវត្តមានសិស្ស', 'ចុចជ្រើសរើសស្ថានភាពវត្តមាន ដូចជា៖ វត្តមាន, យឺត, អវត្តមាន ឬច្បាប់។'),
            const SizedBox(height: 12),
            _buildGuideStep('៣', 'មុខងារ Offline Mode', 'ទោះបីគ្មានអ៊ីនធឺណិត ក៏លោកអ្នកអាចកត់ត្រាវត្តមានបាន ដោយប្រព័ន្ធនឹងរក្សាទុកក្នុងទូរស័ព្ទដោយស្វ័យប្រវត្តិ។'),
            const SizedBox(height: 12),
            _buildGuideStep('៤', 'បញ្ជូនទិន្នន័យ', 'ចុចប៊ូតុង "រក្សាទុកវត្តមាន" ដើម្បីធ្វើសមកាលកម្មទិន្នន័យទៅកាន់ប្រព័ន្ធគ្រប់គ្រងសាលា។'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('យល់ព្រម', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(String num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBorder),
          ),
          child: Center(
            child: Text(num, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleSmall),
              const SizedBox(height: 2),
              Text(desc, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  void _openSecurityModal() {
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
              child: const Icon(LucideIcons.shieldCheck, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('សុវត្ថិភាព និងគោលការណ៍', style: AppTypography.titleMedium),
          ],
        ),
        content: Text(
          'ប្រព័ន្ធ Voatmean ប្រើប្រាស់ស្តង់ដារសុវត្ថិភាពខ្ពស់ និងការការពារទិន្នន័យស្របតាមគោលការណ៍ក្រសួងអប់រំ យុវជន និងកីឡា។ ទិន្នន័យវត្តមាន និងពិន្ទុសិស្សទាំងអស់ត្រូវបានការពារដោយសុវត្ថិភាព។',
          style: AppTypography.bodySmall.copyWith(height: 1.45),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('យល់ព្រម', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
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
          // 1. Teacher Profile Header Card (Clickable to Edit)
          _buildProfileCard(),
          const SizedBox(height: 20),

          // 2. App Settings Section
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
              subtitle: Text('ទទួលការរំលឹកម៉ោងស្រង់វត្តមាន', style: AppTypography.caption),
              value: _notificationsEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v ? 'បានបើកការជូនដំណឹង' : 'បានបិទការជូនដំណឹង', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
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
                    content: Text(v ? 'បានបើក Dark Mode' : 'បានបិទ Dark Mode', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
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
                  color: AppColors.emeraldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.globe, size: 18, color: AppColors.successDark),
              ),
              title: Text('ភាសា (Language)', style: AppTypography.labelMedium),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: Text(_currentLanguage, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSubtle),
                ],
              ),
              onTap: _openLanguageModal,
            ),
          ]),
          const SizedBox(height: 20),

          // 3. Information & Help
          _buildSectionTitle('ព័ត៌មាន & ជំនួយ'),
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
                child: const Icon(LucideIcons.helpCircle, size: 18, color: AppColors.primary),
              ),
              title: Text('របៀបស្រង់វត្តមានសិស្ស', style: AppTypography.labelMedium),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSubtle),
              onTap: _openHelpGuideModal,
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
                child: const Icon(LucideIcons.shieldCheck, size: 18, color: AppColors.textSecondary),
              ),
              title: Text('សុវត្ថិភាព និងគោលការណ៍', style: AppTypography.labelMedium),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSubtle),
              onTap: _openSecurityModal,
            ),
          ]),
          const SizedBox(height: 20),

          // 4. Account Actions
          _buildSectionTitle('សកម្មភាពគណនី'),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            if (widget.onSwitchToAdminPortal != null) ...[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.layoutDashboard, size: 18, color: AppColors.primary),
                ),
                title: Text('ប្តូរទៅកាន់ Admin Portal', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.primary),
                onTap: widget.onSwitchToAdminPortal,
              ),
              const Divider(height: 1, indent: 56, color: AppColors.border),
            ],
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
              title: Text('ចាកចេញពីកម្មវិធី', style: AppTypography.labelMedium.copyWith(color: AppColors.danger)),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.danger),
              onTap: _confirmSignOut,
            ),
          ]),
          const SizedBox(height: 24),

          // App Version footer
          Center(
            child: Text(
              'Voatmean Attendance • v1.0.0',
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
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openEditProfileModal,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    _teacherName.isNotEmpty ? _teacherName.substring(0, 1) : 'ស',
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
                              _teacherName,
                              style: AppTypography.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.emeraldBorder),
                            ),
                            child: Text(
                              'គ្រូបង្រៀន',
                              style: AppTypography.captionBold.copyWith(color: AppColors.emeraldText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'មុខវិជ្ជា៖ $_teacherSubject • វិទ្យាល័យ ហ៊ុន សែន',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ទូរស័ព្ទ៖ $_teacherPhone',
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.edit3, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
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
