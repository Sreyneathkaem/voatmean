import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import 'package:voatmean_mobile/core/theme/theme_provider.dart';
import 'package:voatmean_mobile/core/localization/locale_provider.dart';
import 'package:voatmean_mobile/core/localization/app_translations.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool('teacher_notifications_enabled');
      if (val != null && mounted) {
        setState(() => _notificationsEnabled = val);
      }
    } catch (e) {
      debugPrint('Error loading teacher notification pref: $e');
    }
  }

  Future<void> _toggleNotificationPref(bool val) async {
    setState(() => _notificationsEnabled = val);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('teacher_notifications_enabled', val);
    } catch (e) {
      debugPrint('Error saving teacher notification pref: $e');
    }
  }

  String _teacherName = 'លោកគ្រូ សុខ សំណាង';
  String _teacherPhone = '012 345 678';
  String _teacherSubject = 'គណិតវិទ្យា';

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
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
            Text(context.tr('sign_out_confirm_title'), style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context))),
          ],
        ),
        content: Text(
          context.tr('sign_out_confirm_teacher'),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryOf(context)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel'), style: AppTypography.labelMedium.copyWith(color: AppColors.textMutedOf(context))),
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
            child: Text(context.tr('sign_out'), style: AppTypography.labelMedium.copyWith(color: Colors.white)),
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

  void _openLanguageModal(BuildContext context, LocaleProvider localeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    Text(
                      context.tr('choose_language'),
                      style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context)),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(LucideIcons.x, size: 20, color: AppColors.textMutedOf(context)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              title: Text('ភាសាខ្មែរ (Khmer)', style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryOf(context))),
              trailing: localeProvider.isKhmer
                  ? const Icon(LucideIcons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                localeProvider.setLanguageCode('km');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('បានប្តូរភាសាទៅជាភាសាខ្មែរ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            Divider(height: 1, color: AppColors.borderOf(context)),
            ListTile(
              title: Text('English (US)', style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryOf(context))),
              trailing: !localeProvider.isKhmer
                  ? const Icon(LucideIcons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                localeProvider.setLanguageCode('en');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language switched to English', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      appBar: AppBar(
        title: Text(context.tr('settings_title'), style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context))),
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
          // 1. Teacher Profile Header Card (Clickable to Edit)
          _buildProfileCard(),
          const SizedBox(height: 20),

          // 2. App Settings Section
          _buildSectionTitle(context.tr('section_app_settings')),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _notificationsEnabled
                      ? (isDark ? const Color(0xFF1E3A8A) : AppColors.primaryLight)
                      : AppColors.slateBgOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _notificationsEnabled ? LucideIcons.bell : LucideIcons.bellOff,
                  size: 18,
                  color: _notificationsEnabled
                      ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                      : AppColors.textMutedOf(context),
                ),
              ),
              title: Text(context.tr('notifications'), style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimaryOf(context))),
              subtitle: Text(
                _notificationsEnabled
                    ? context.tr('notifications_sub_teacher')
                    : (Localizations.localeOf(context).languageCode == 'km' ? 'បានបិទការជូនដំណឹង (បានផ្អាក)' : 'Notifications disabled'),
                style: AppTypography.caption.copyWith(color: AppColors.textMutedOf(context)),
              ),
              value: _notificationsEnabled,
              onChanged: (v) {
                _toggleNotificationPref(v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v ? context.tr('notif_enabled') : context.tr('notif_disabled'), style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                    backgroundColor: v ? AppColors.primary : AppColors.textSecondaryOf(context),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            Divider(height: 1, indent: 56, color: AppColors.borderOf(context)),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? const Color(0xFF312E81)
                      : AppColors.slateBgOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  themeProvider.isDarkMode ? LucideIcons.moonStar : LucideIcons.sun,
                  size: 18,
                  color: themeProvider.isDarkMode
                      ? const Color(0xFFA5B4FC)
                      : const Color(0xFFF59E0B),
                ),
              ),
              title: Text(context.tr('dark_mode'), style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimaryOf(context))),
              subtitle: Text(context.tr('dark_mode_sub'), style: AppTypography.caption.copyWith(color: AppColors.textMutedOf(context))),
              value: themeProvider.isDarkMode,
              onChanged: (v) {
                themeProvider.toggleTheme(v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v ? context.tr('dark_mode_enabled') : context.tr('dark_mode_disabled'), style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            Divider(height: 1, indent: 56, color: AppColors.borderOf(context)),
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
              title: Text(context.tr('language'), style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimaryOf(context))),
              subtitle: Text(context.tr('language_sub'), style: AppTypography.caption.copyWith(color: AppColors.textMutedOf(context))),
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
                    child: Text(localeProvider.languageName, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(width: 6),
                  Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSubtleOf(context)),
                ],
              ),
              onTap: () => _openLanguageModal(context, localeProvider),
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
              title: Text(context.tr('help_guide'), style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimaryOf(context))),
              subtitle: Text(context.tr('help_guide_sub'), style: AppTypography.caption.copyWith(color: AppColors.textMutedOf(context))),
              trailing: Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSubtleOf(context)),
              onTap: _openHelpGuideModal,
            ),
            Divider(height: 1, indent: 56, color: AppColors.borderOf(context)),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.slateBgOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.shieldCheck, size: 18, color: AppColors.textSecondaryOf(context)),
              ),
              title: Text(context.tr('security_policy'), style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimaryOf(context))),
              subtitle: Text(context.tr('security_policy_sub'), style: AppTypography.caption.copyWith(color: AppColors.textMutedOf(context))),
              trailing: Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSubtleOf(context)),
              onTap: _openSecurityModal,
            ),
          ]),
          const SizedBox(height: 20),

          // 4. Account Actions
          _buildSectionTitle(context.tr('section_actions')),
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
                title: Text(context.tr('switch_to_admin'), style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.primary),
                onTap: widget.onSwitchToAdminPortal,
              ),
              Divider(height: 1, indent: 56, color: AppColors.borderOf(context)),
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
              title: Text(context.tr('sign_out'), style: AppTypography.labelMedium.copyWith(color: AppColors.danger)),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.danger),
              onTap: _confirmSignOut,
            ),
          ]),
          const SizedBox(height: 24),

          // App Version footer
          Center(
            child: Text(
              'Voatmean Attendance • v1.0.0',
              style: AppTypography.caption.copyWith(color: AppColors.textSubtleOf(context)),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppColors.cardShadowOf(context),
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
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimaryOf(context),
                                fontWeight: FontWeight.bold,
                              ),
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
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryOf(context)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ទូរស័ព្ទ៖ $_teacherPhone',
                        style: AppTypography.caption.copyWith(color: AppColors.textMutedOf(context)),
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
        style: AppTypography.labelMedium.copyWith(color: AppColors.textMutedOf(context)),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppColors.cardShadowOf(context),
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
