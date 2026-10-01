import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'km': {
      // General / Common
      'app_name': 'វត្តមាន',
      'save': 'រក្សាទុក',
      'cancel': 'បោះបង់',
      'close': 'បិទ',
      'success': 'ជោគជ័យ',
      'error': 'បរាជ័យ',
      'confirm': 'យល់ព្រម',
      'search': 'ស្វែងរក...',

      // Admin Navigation
      'nav_dashboard': 'ផ្ទាំងគ្រប់គ្រង',
      'nav_classes': 'ចាត់តាំងថ្នាក់',
      'nav_teachers': 'គ្រូបង្រៀន',
      'nav_students': 'សិស្ស',
      'nav_settings': 'ការកំណត់',

      // Teacher Navigation
      'nav_schedule': 'កាលវិភាគ',
      'nav_reports': 'របាយការណ៍',

      // Settings Screen
      'settings_title': 'ការកំណត់',
      'section_account': 'គណនី និងសុវត្ថិភាព',
      'personal_info': 'ព័ត៌មានផ្ទាល់ខ្លួន',
      'personal_info_sub': 'កែសម្រួលឈ្មោះ អ៊ីមែល និងសាលារៀន',
      'change_password': 'ប្តូរពាក្យសម្ងាត់',
      'change_password_sub': 'ផ្លាស់ប្តូរលេខកូដសម្ងាត់គណនី',

      'section_app_settings': 'ការកំណត់កម្មវិធី',
      'notifications': 'ការជូនដំណឹង',
      'notifications_sub_admin': 'ទទួលដំណឹងពីការស្រង់វត្តមានរបស់គ្រូ',
      'notifications_sub_teacher': 'ទទួលការរំលឹកម៉ោងស្រង់វត្តមាន',
      'dark_mode': 'មុខងារងងឹត (Dark Mode)',
      'dark_mode_sub': 'ប្តូរផ្ទៃកម្មវិធីជាពណ៌ងងឹត',
      'language': 'ភាសា (Language)',
      'language_sub': 'ជ្រើសរើសភាសាប្រើប្រាស់',
      'score_formula': 'រូបមន្តគណនាពិន្ទុ (Score Formula)',
      'score_formula_sub': 'កំណត់ទម្ងន់ពិន្ទុវត្តមាន និងពិន្ទុគ្រូដាក់',
      'manage_subjects': 'គ្រប់គ្រងមុខវិជ្ជា (Manage Subjects)',
      'manage_subjects_sub': 'មើលបញ្ជីមុខវិជ្ជា និងបង្កើតមុខវិជ្ជាបន្ថែម',
      'help_guide': 'របៀបស្រង់វត្តមានសិស្ស',
      'help_guide_sub': 'មគ្គុទ្ទេសក៍ណែនាំសម្រាប់គ្រូបង្រៀន',
      'security_policy': 'សុវត្ថិភាព និងគោលការណ៍',
      'security_policy_sub': 'ស្តង់ដារសុវត្ថិភាព និងការការពារទិន្នន័យ',

      'section_actions': 'សកម្មភាព',
      'switch_to_teacher': 'ប្តូរទៅកាន់ Teacher Portal',
      'switch_to_admin': 'ប្តូរទៅកាន់ Admin Dashboard',
      'sign_out': 'ចាកចេញពីកម្មវិធី',

      // Dialogs & Modals
      'sign_out_confirm_title': 'ចាកចេញពីកម្មវិធី',
      'sign_out_confirm_admin': 'តើលោកអ្នកពិតជាចង់ចាកចេញពីគណនីអ្នកគ្រប់គ្រងមែនទេ?',
      'sign_out_confirm_teacher': 'តើលោកអ្នកពិតជាចង់ចាកចេញពីគណនីគ្រូបង្រៀនមែនទេ?',
      'choose_language': 'ជ្រើសរើសភាសា (Select Language)',

      // Toasts
      'dark_mode_enabled': 'បានបើក Dark Mode',
      'dark_mode_disabled': 'បានប្តូរទៅកាន់មុខងារពន្លឺ (Light Mode)',
      'notif_enabled': 'បានបើកការជូនដំណឹង',
      'notif_disabled': 'បានបិទការជូនដំណឹង',
      'lang_switched': 'បានប្តូរភាសាទៅជាភាសាខ្មែរ',
    },
    'en': {
      // General / Common
      'app_name': 'Voatmean',
      'save': 'Save',
      'cancel': 'Cancel',
      'close': 'Close',
      'success': 'Success',
      'error': 'Error',
      'confirm': 'Confirm',
      'search': 'Search...',

      // Admin Navigation
      'nav_dashboard': 'Dashboard',
      'nav_classes': 'Classes',
      'nav_teachers': 'Teachers',
      'nav_students': 'Students',
      'nav_settings': 'Settings',

      // Teacher Navigation
      'nav_schedule': 'Schedule',
      'nav_reports': 'Reports',

      // Settings Screen
      'settings_title': 'Settings',
      'section_account': 'Account & Security',
      'personal_info': 'Personal Information',
      'personal_info_sub': 'Edit name, email and school details',
      'change_password': 'Change Password',
      'change_password_sub': 'Update your account login password',

      'section_app_settings': 'App Settings',
      'notifications': 'Notifications',
      'notifications_sub_admin': 'Receive alerts on teacher attendance entries',
      'notifications_sub_teacher': 'Receive attendance session reminders',
      'dark_mode': 'Dark Mode',
      'dark_mode_sub': 'Switch app interface to sleek dark theme',
      'language': 'Language',
      'language_sub': 'Select your preferred app language',
      'score_formula': 'Score Formula',
      'score_formula_sub': 'Configure attendance and teacher score weights',
      'manage_subjects': 'Manage Subjects',
      'manage_subjects_sub': 'Browse and create school subjects',
      'help_guide': 'Attendance Guide',
      'help_guide_sub': 'Step-by-step instructions for teachers',
      'security_policy': 'Security & Policies',
      'security_policy_sub': 'Data security and privacy standards',

      'section_actions': 'Actions',
      'switch_to_teacher': 'Switch to Teacher Portal',
      'switch_to_admin': 'Switch to Admin Dashboard',
      'sign_out': 'Sign Out',

      // Dialogs & Modals
      'sign_out_confirm_title': 'Sign Out',
      'sign_out_confirm_admin': 'Are you sure you want to sign out from the Admin account?',
      'sign_out_confirm_teacher': 'Are you sure you want to sign out from the Teacher account?',
      'choose_language': 'Select Language',

      // Toasts
      'dark_mode_enabled': 'Dark Mode enabled',
      'dark_mode_disabled': 'Light Mode enabled',
      'notif_enabled': 'Notifications enabled',
      'notif_disabled': 'Notifications disabled',
      'lang_switched': 'Language switched to English',
    },
  };

  static String get(BuildContext context, String key) {
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: true);
      final lang = localeProvider.locale.languageCode;
      return _localizedValues[lang]?[key] ?? _localizedValues['km']?[key] ?? key;
    } catch (_) {
      return _localizedValues['km']?[key] ?? key;
    }
  }

  static String of(BuildContext context, String key) => get(context, key);
}

extension TranslationExtension on BuildContext {
  String tr(String key) => AppTranslations.get(this, key);
}
