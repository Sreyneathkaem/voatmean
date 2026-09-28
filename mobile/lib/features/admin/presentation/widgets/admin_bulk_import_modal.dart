import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';

import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import '../../data/services/admin_service.dart';

enum BulkImportType { students, teachers }

class AdminBulkImportModal extends StatefulWidget {
  final BulkImportType importType;
  final VoidCallback onImportSuccess;

  const AdminBulkImportModal({
    super.key,
    required this.importType,
    required this.onImportSuccess,
  });

  static void show(
    BuildContext context, {
    required BulkImportType importType,
    required VoidCallback onImportSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminBulkImportModal(
        importType: importType,
        onImportSuccess: onImportSuccess,
      ),
    );
  }

  @override
  State<AdminBulkImportModal> createState() => _AdminBulkImportModalState();
}

class _AdminBulkImportModalState extends State<AdminBulkImportModal> {
  final TextEditingController _textController = TextEditingController();
  final AdminService _adminService = AdminService();

  List<Map<String, dynamic>> _parsedRecords = [];
  bool _isImporting = false;
  int _activeTab = 0; // 0 = File Drop/Upload, 1 = Paste, 2 = Preview
  String? _selectedFileName;
  String? _selectedFileSize;
  bool _isLoadingFile = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _parseText(_textController.text);
  }

  /// Intelligent parser that detects delimiters, headers, and maps columns automatically
  void _parseText(String rawText) {
    if (rawText.trim().isEmpty) {
      setState(() => _parsedRecords = []);
      return;
    }

    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      setState(() => _parsedRecords = []);
      return;
    }

    // 1. Detect separator delimiter (tab \t, comma ,, semicolon ;, pipe |)
    final sample = lines.first;
    int tabCount = sample.split('\t').length;
    int commaCount = sample.split(',').length;
    int semiCount = sample.split(';').length;
    int pipeCount = sample.split('|').length;

    String sep = '\t';
    int maxCols = tabCount;
    if (commaCount > maxCols) {
      sep = ',';
      maxCols = commaCount;
    }
    if (semiCount > maxCols) {
      sep = ';';
      maxCols = semiCount;
    }
    if (pipeCount > maxCols) {
      sep = '|';
      maxCols = pipeCount;
    }

    // 2. Detect if first line is a header row
    final headerTokens = lines.first.split(sep).map((t) => t.trim().toLowerCase()).toList();
    bool hasHeader = headerTokens.any((t) =>
        t.contains('ឈ្មោះ') ||
        t.contains('name') ||
        t.contains('ភេទ') ||
        t.contains('gender') ||
        t.contains('ថ្នាក់') ||
        t.contains('class') ||
        t.contains('grade') ||
        t.contains('ល.រ') ||
        t.contains('roll') ||
        t.contains('phone') ||
        t.contains('ទូរស័ព្ទ') ||
        t.contains('subject') ||
        t.contains('មុខវិជ្ជា'));

    int nameIdx = -1;
    int genderIdx = -1;
    int classIdx = -1;
    int phoneIdx = -1;
    int rollIdx = -1;
    int guardianIdx = -1;
    int subjectIdx = -1;
    int emailIdx = -1;

    if (hasHeader) {
      for (int i = 0; i < headerTokens.length; i++) {
        final t = headerTokens[i];
        if (nameIdx == -1 && (t.contains('ឈ្មោះ') || t.contains('name') || t.contains('គោត្តនាម'))) {
          nameIdx = i;
        } else if (genderIdx == -1 && (t.contains('ភេទ') || t.contains('gender') || t.contains('sex'))) {
          genderIdx = i;
        } else if (classIdx == -1 && (t.contains('ថ្នាក់') || t.contains('class') || t.contains('grade'))) {
          classIdx = i;
        } else if (phoneIdx == -1 && (t.contains('ទូរស័ព្ទ') || t.contains('phone') || t.contains('tel'))) {
          phoneIdx = i;
        } else if (rollIdx == -1 && (t.contains('ល.រ') || t.contains('លេខ') || t.contains('roll') || t.contains('no'))) {
          rollIdx = i;
        } else if (guardianIdx == -1 && (t.contains('អាណាព្យាបាល') || t.contains('guardian') || t.contains('parent'))) {
          guardianIdx = i;
        } else if (subjectIdx == -1 && (t.contains('មុខវិជ្ជា') || t.contains('subject') || t.contains('major'))) {
          subjectIdx = i;
        } else if (emailIdx == -1 && (t.contains('អ៊ីមែល') || t.contains('email') || t.contains('mail'))) {
          emailIdx = i;
        }
      }
    }

    final dataLines = hasHeader ? lines.sublist(1) : lines;
    final List<Map<String, dynamic>> results = [];

    for (int rIdx = 0; rIdx < dataLines.length; rIdx++) {
      final line = dataLines[rIdx];
      final parts = line.split(sep).map((p) => p.trim()).toList();
      if (parts.isEmpty || (parts.length == 1 && parts.first.isEmpty)) continue;

      String name = '';
      String gender = 'Male';
      String className = 'Grade 10A';
      String roll = '${rIdx + 1}';
      String phone = '';
      String guardianPhone = '';
      String subject = 'Mathematics';
      String email = '';

      if (hasHeader) {
        if (nameIdx != -1 && nameIdx < parts.length) name = parts[nameIdx];
        if (genderIdx != -1 && genderIdx < parts.length) gender = _normalizeGender(parts[genderIdx]);
        if (classIdx != -1 && classIdx < parts.length) className = _normalizeClass(parts[classIdx]);
        if (rollIdx != -1 && rollIdx < parts.length && parts[rollIdx].isNotEmpty) roll = parts[rollIdx];
        if (phoneIdx != -1 && phoneIdx < parts.length) phone = parts[phoneIdx];
        if (guardianIdx != -1 && guardianIdx < parts.length) guardianPhone = parts[guardianIdx];
        if (subjectIdx != -1 && subjectIdx < parts.length) subject = _normalizeSubject(parts[subjectIdx]);
        if (emailIdx != -1 && emailIdx < parts.length) email = parts[emailIdx];
      } else {
        // Positional / Heuristic Detection
        // Typically: Col 0 = Roll or Name, Col 1 = Name or Gender, etc.
        for (int pIdx = 0; pIdx < parts.length; pIdx++) {
          final val = parts[pIdx];
          if (val.isEmpty) continue;

          // Check for Gender
          if (val == 'ប្រុស' || val == 'ស្រី' || val.toLowerCase() == 'male' || val.toLowerCase() == 'female' || val == 'M' || val == 'F') {
            gender = _normalizeGender(val);
          }
          // Check for Class (e.g. 10A, 11B, Grade 10A)
          else if (RegExp(r'^(\d+[A-Za-z]|Grade\s*\d+[A-Za-z]|ថ្នាក់.*)$', caseSensitive: false).hasMatch(val)) {
            className = _normalizeClass(val);
          }
          // Check for Phone
          else if (RegExp(r'^(0\d{8,9}|\+855\d{8,9})$').hasMatch(val.replaceAll(' ', ''))) {
            if (phone.isEmpty) {
              phone = val;
            } else if (guardianPhone.isEmpty) {
              guardianPhone = val;
            }
          }
          // Check for Roll Number (small digits at beginning)
          else if (pIdx == 0 && RegExp(r'^\d{1,3}$').hasMatch(val)) {
            roll = val;
          }
          // Check for Email
          else if (val.contains('@')) {
            email = val;
          }
          // Text -> Name or Subject
          else {
            if (name.isEmpty) {
              name = val;
            } else if (widget.importType == BulkImportType.teachers && subject.isEmpty) {
              subject = _normalizeSubject(val);
            }
          }
        }
      }

      if (name.isNotEmpty) {
        if (widget.importType == BulkImportType.students) {
          results.add({
            'full_name': name,
            'gender': gender,
            'class_name': className,
            'roll_number': roll,
            'phone_number': phone.isNotEmpty ? phone : '012 345 678',
            'guardian_phone': guardianPhone.isNotEmpty ? guardianPhone : phone,
          });
        } else {
          results.add({
            'full_name': name,
            'gender': gender,
            'subject': subject,
            'classes': [className],
            'phone': phone.isNotEmpty ? phone : '012 345 678',
            'email': email.isNotEmpty ? email : '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '.')}.${DateTime.now().millisecondsSinceEpoch % 1000}@voatmean.edu.kh',
          });
        }
      }
    }

    setState(() {
      _parsedRecords = results;
    });
  }

  String _normalizeGender(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'ស្រី' || lower == 'female' || lower == 'f' || lower == 'ស') return 'Female';
    return 'Male';
  }

  String _normalizeClass(String raw) {
    String trimmed = raw.trim();
    if (RegExp(r'^\d+[A-Za-z]$').hasMatch(trimmed)) {
      return 'Grade ${trimmed.toUpperCase()}';
    }
    if (trimmed.startsWith('ថ្នាក់ទី') || trimmed.startsWith('ថ្នាក់')) {
      return trimmed.replaceFirst('ថ្នាក់ទី', 'Grade ').replaceFirst('ថ្នាក់', 'Grade ').trim();
    }
    return trimmed.isNotEmpty ? trimmed : 'Grade 10A';
  }

  String _normalizeSubject(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains('គណិត') || trimmed.toLowerCase().contains('math')) return 'Mathematics';
    if (trimmed.contains('អក្សរ') || trimmed.contains('ខ្មែរ') || trimmed.toLowerCase().contains('khmer')) return 'Khmer Literature';
    if (trimmed.contains('រូប') || trimmed.toLowerCase().contains('physic')) return 'Physics';
    if (trimmed.contains('គីមី') || trimmed.toLowerCase().contains('chem')) return 'Chemistry';
    if (trimmed.contains('ជីវ') || trimmed.toLowerCase().contains('bio')) return 'Biology';
    if (trimmed.contains('អង់គ្លេស') || trimmed.toLowerCase().contains('english')) return 'English';
    if (trimmed.contains('ប្រវត្តិ') || trimmed.toLowerCase().contains('hist')) return 'History';
    if (trimmed.contains('ភូមិ') || trimmed.toLowerCase().contains('geo')) return 'Geography';
    return trimmed.isNotEmpty ? trimmed : 'Mathematics';
  }

  /// Processes an XFile (from file picker or drag-and-drop)
  Future<void> _processXFile(XFile xfile) async {
    try {
      setState(() => _isLoadingFile = true);
      final name = xfile.name;
      final extension = name.contains('.') ? name.split('.').last.toLowerCase() : '';
      final bytes = await xfile.readAsBytes();

      if (bytes.isEmpty) {
        setState(() => _isLoadingFile = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ឯកសារទទេ មិនអាចអានបានទេ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }

      String extractedText = '';

      if (extension == 'xlsx' || extension == 'xls') {
        final excel = Excel.decodeBytes(bytes);
        final buffer = StringBuffer();
        for (final table in excel.tables.keys) {
          final sheet = excel.tables[table]!;
          for (final row in sheet.rows) {
            final rowValues = row.map((cell) {
              if (cell == null || cell.value == null) return '';
              return cell.value.toString().trim();
            }).toList();
            if (rowValues.any((val) => val.isNotEmpty)) {
              buffer.writeln(rowValues.join('\t'));
            }
          }
          break; // Read primary sheet
        }
        extractedText = buffer.toString();
      } else {
        try {
          extractedText = utf8.decode(bytes);
        } catch (_) {
          extractedText = latin1.decode(bytes);
        }
      }

      if (mounted) {
        setState(() {
          _isLoadingFile = false;
          _selectedFileName = name;
          _selectedFileSize = '${(bytes.length / 1024).toStringAsFixed(1)} KB';
          _textController.text = extractedText;
        });
        _parseText(extractedText);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('បានផ្ទុកឯកសារ $name ដោយជោគជ័យ (${_parsedRecords.length} ជួរ)',
                style: AppTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        if (_parsedRecords.isNotEmpty) {
          setState(() => _activeTab = 2); // Switch directly to Preview tab
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('មានបញ្ហាក្នុងការអានឯកសារ៖ $e', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Picks and processes an Excel (.xlsx, .xls) or text (.csv, .tsv, .txt) file
  Future<void> _pickAndProcessFile() async {
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls', 'tsv', 'txt'],
      );

      if (picked == null) {
        return;
      }

      await _processXFile(picked.xFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('មិនអាចជ្រើសរើសឯកសារបានទេ៖ $e', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildFormatChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.firaCode(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
      _parseText(data.text!);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('បានបិទភ្ជាប់ទិន្នន័យពី Clipboard', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('មិនមានទិន្នន័យក្នុង Clipboard ទេ', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: AppColors.warningText,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _loadSampleData() {
    if (widget.importType == BulkImportType.students) {
      _textController.text =
          "ល.រ\tឈ្មោះសិស្ស\tភេទ\tថ្នាក់\tលេខទូរស័ព្ទ\n"
          "1\tសុខ ពិសិដ្ឋ\tប្រុស\tGrade 10A\t012345678\n"
          "2\tកែវ មុន្នី\tស្រី\tGrade 10A\t012888999\n"
          "3\tចាន់ រដ្ឋា\tប្រុស\tGrade 10A\t015666777\n"
          "4\tហេង ស្រីពៅ\tស្រី\tGrade 10B\t016555444\n"
          "5\tជា វីរៈ\tប្រុស\tGrade 10B\t017333222\n"
          "6\tលី ធីតា\tស្រី\tGrade 11A\t018222111\n"
          "7\tម៉េង បូរ៉ា\tប្រុស\tGrade 11A\t019111000\n"
          "8\tទេព ចិន្តា\tស្រី\tGrade 12B\t089999888\n"
          "9\tគង់ វិសាល\tប្រុស\tGrade 12B\t077888777\n"
          "10\tព្រំ រស្មី\tស្រី\tGrade 12B\t098777666";
    } else {
      _textController.text =
          "ឈ្មោះគ្រូបង្រៀន\tភេទ\tមុខវិជ្ជា\tថ្នាក់បង្រៀន\tលេខទូរស័ព្ទ\tអ៊ីមែល\n"
          "អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)\tស្រី\tគណិតវិទ្យា\tGrade 10A, Grade 11A, Grade 12B\t012345678\tk.sreyneath24@gmail.com\n"
          "អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)\tស្រី\tរូបវិទ្យា\tGrade 10B, Grade 11B, Grade 12A\t098765432\tneangsrey137@gmail.com";
    }
    _parseText(_textController.text);
  }

  Future<void> _submitImport() async {
    if (_parsedRecords.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      Map<String, dynamic>? res;
      if (widget.importType == BulkImportType.students) {
        res = await _adminService.bulkImportStudents(_parsedRecords);
      } else {
        res = await _adminService.bulkImportTeachers(_parsedRecords);
      }

      if (!mounted) return;
      setState(() => _isImporting = false);

      if (res != null && res['success'] == true) {
        navigator.pop();
        widget.onImportSuccess();
        final count = res['imported_count'] ?? _parsedRecords.length;
        final updated = res['updated_count'] ?? 0;
        final typeName = widget.importType == BulkImportType.students ? 'សិស្ស' : 'គ្រូ';
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              '🎉 បាននាំចូល$typeNameជោគជ័យចំនួន $count នាក់ ${updated > 0 ? '(កែប្រែ $updated)' : ''}',
              style: AppTypography.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'បរាជ័យក្នុងការនាំចូលទិន្នន័យ៖ ${res?['error'] ?? 'សូមពិនិត្យទម្រង់ទិន្នន័យ'}',
              style: AppTypography.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.importType == BulkImportType.students;
    final title = isStudent ? 'នាំចូលបញ្ជីសិស្សពី Sheet (Smart Import)' : 'នាំចូលបញ្ជីគ្រូពី Sheet (Smart Import)';
    final detectedClasses = isStudent
        ? _parsedRecords.map((r) => r['class_name']?.toString() ?? '').toSet().where((c) => c.isNotEmpty).toList()
        : <String>[];

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.fileSpreadsheet, color: Color(0xFF16A34A), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'បិទភ្ជាប់ពី Excel ឬ Google Sheet ដោយស្វ័យប្រវត្តិ',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tabs: 0 = Drop / File, 1 = Paste Text, 2 = Preview & Validate
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.slateBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 0),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _activeTab == 0
                            ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 4)]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '📁 ទម្លាក់ File',
                          style: _activeTab == 0 ? AppTypography.labelMedium : AppTypography.bodySmall,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 1),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _activeTab == 1
                            ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 4)]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '📋 បិទភ្ជាប់ (Paste)',
                          style: _activeTab == 1 ? AppTypography.labelMedium : AppTypography.bodySmall,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 2),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeTab == 2 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _activeTab == 2
                            ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 4)]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '👁️ លទ្ធផល',
                              style: _activeTab == 2 ? AppTypography.labelMedium : AppTypography.bodySmall,
                            ),
                            if (_parsedRecords.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_parsedRecords.length}',
                                  style: AppTypography.captionBold.copyWith(color: AppColors.primary, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // TAB 0: FILE DROP / UPLOAD
          if (_activeTab == 0) ...[
            Expanded(
              child: DropTarget(
                onDragEntered: (detail) => setState(() => _isDragging = true),
                onDragExited: (detail) => setState(() => _isDragging = false),
                onDragDone: (detail) async {
                  setState(() => _isDragging = false);
                  if (detail.files.isNotEmpty) {
                    await _processXFile(detail.files.first);
                  }
                },
                child: InkWell(
                  onTap: _isLoadingFile ? null : _pickAndProcessFile,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: _isDragging
                          ? const Color(0xFFEFF6FF)
                          : _selectedFileName != null
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isDragging
                            ? AppColors.primary
                            : _selectedFileName != null
                                ? const Color(0xFF16A34A)
                                : AppColors.primary.withValues(alpha: 0.35),
                        width: _isDragging ? 2.5 : 1.6,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoadingFile) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 14),
                          Text('កំពុងអានទិន្នន័យឯកសារ...', style: AppTypography.bodyMedium),
                        ] else if (_isDragging) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.arrowDownCircle, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'លែងឯកសារនៅទីនេះដើម្បីទម្លាក់ (Drop Here)',
                            style: AppTypography.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ប្រព័ន្ធនឹងអានទិន្នន័យដោយស្វ័យប្រវត្តិ',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ] else if (_selectedFileName != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCFCE7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.fileSpreadsheet, size: 38, color: Color(0xFF16A34A)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedFileName!,
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Text(
                              'ទំហំ: $_selectedFileSize • ${_parsedRecords.length} ជួរត្រៀមនាំចូល',
                              style: AppTypography.captionBold.copyWith(color: const Color(0xFF16A34A)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickAndProcessFile,
                                icon: const Icon(LucideIcons.folderOpen, size: 14),
                                label: Text('ប្តូរឯកសារ', style: AppTypography.captionBold),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () => setState(() => _activeTab = 2),
                                icon: const Icon(LucideIcons.arrowRight, size: 14),
                                label: Text('ពិនិត្យលទ្ធផល (${_parsedRecords.length})',
                                    style: AppTypography.captionBold.copyWith(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.uploadCloud, size: 40, color: AppColors.primary),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'ទម្លាក់ឯកសារ Excel ឬ CSV នៅទីនេះ',
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ចុចទីនេះដើម្បីជ្រើសរើសឯកសារ ឬអូសទម្លាក់ផ្ទាល់',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFormatChip('.xlsx'),
                              _buildFormatChip('.xls'),
                              _buildFormatChip('.csv'),
                              _buildFormatChip('.tsv'),
                              _buildFormatChip('.txt'),
                            ],
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _pickAndProcessFile,
                            icon: const Icon(LucideIcons.fileSpreadsheet, size: 16),
                            label: Text('ជ្រើសរើសឯកសារ (Browse File)',
                                style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _loadSampleData();
                      setState(() => _activeTab = 2);
                    },
                    icon: const Icon(LucideIcons.sparkles, size: 14, color: Color(0xFF10B981)),
                    label: Text('✨ សាកល្បងជាមួយទិន្នន័យគំរូ',
                        style: AppTypography.captionBold.copyWith(color: const Color(0xFF10B981))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF86EFAC)),
                      backgroundColor: const Color(0xFFF0FDF4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // TAB 1: PASTE / TEXT INPUT
          if (_activeTab == 1) ...[
            // Quick Action Buttons Bar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(LucideIcons.clipboardPaste, size: 15),
                    label: Text('បិទភ្ជាប់ Clipboard', style: AppTypography.labelSmall),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadSampleData,
                    icon: const Icon(LucideIcons.sparkles, size: 15),
                    label: Text('ទិន្នន័យគំរូ', style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (_textController.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
                    tooltip: 'សម្អាត',
                    onPressed: () {
                      _textController.clear();
                      setState(() {
                        _selectedFileName = null;
                        _selectedFileSize = null;
                        _parsedRecords = [];
                      });
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Big Text Area for Sheet records
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.slateBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.firaCode(fontSize: 12, height: 1.5, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(14),
                    border: InputBorder.none,
                    hintText: isStudent
                        ? "ចម្លង (Copy) ជួរដេកពី Excel ឬ Google Sheet រួចបិទភ្ជាប់ (Paste) នៅទីនេះ...\n\n"
                          "ប្រព័ន្ធគាំទ្រគ្រប់ទម្រង់៖ Comma, Tab, ឬ Space\n"
                          "ក្បាលតារាងគំរូ៖\n"
                          "ល.រ\tឈ្មោះសិស្ស\tភេទ\tថ្នាក់\tលេខទូរស័ព្ទ\n"
                          "1\tសុខ ពិសិដ្ឋ\tប្រុស\t10A\t012345678\n"
                          "2\tកែវ មុន្នី\tស្រី\t10A\t098765432"
                        : "ចម្លង (Copy) ជួរដេកគ្រូបង្រៀនពី Excel/Sheet រួចបិទភ្ជាប់នៅទីនេះ...\n\n"
                          "ក្បាលតារាងគំរូ៖\n"
                          "ឈ្មោះគ្រូ\tភេទ\tមុខវិជ្ជា\tថ្នាក់បង្រៀន\tលេខទូរស័ព្ទ\n"
                          "សុខ សំណាង\tប្រុស\tគណិតវិទ្យា\tGrade 10A, 10B\t012999888",
                    hintStyle: GoogleFonts.firaCode(fontSize: 11, color: AppColors.textSubtle),
                  ),
                ),
              ),
            ),
          ],

          // TAB 2: PREVIEW & CONFIRM
          if (_activeTab == 2) ...[
            // Status and Summary Banner
            if (_parsedRecords.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.fileQuestion, size: 48, color: AppColors.textSubtle),
                      const SizedBox(height: 12),
                      Text('មិនទាន់មានទិន្នន័យនៅឡើយ', style: AppTypography.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'សូមត្រលប់ទៅផ្ទាំង "បិទភ្ជាប់ទិន្នន័យ" ដើម្បីបិទភ្ជាប់ ឬសាកល្បងទិន្នន័យគំរូ',
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () {
                          _loadSampleData();
                          setState(() => _activeTab = 1);
                        },
                        icon: const Icon(LucideIcons.sparkles, size: 16),
                        label: const Text('ផ្ទុកទិន្នន័យគំរូ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Summary Chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x334F46E5)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'រកឃើញទិន្នន័យត្រឹមត្រូវ ${_parsedRecords.length} នាក់ ${detectedClasses.isNotEmpty ? 'ក្នុង ${detectedClasses.length} ថ្នាក់' : ''}',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              if (detectedClasses.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: detectedClasses.map((cls) {
                    final count = _parsedRecords.where((r) => r['class_name'] == cls).length;
                    return Chip(
                      label: Text('$cls ($count នាក់)', style: AppTypography.captionBold.copyWith(fontSize: 11)),
                      backgroundColor: AppColors.slateBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 10),

              // Scrollable Preview List
              Expanded(
                child: ListView.separated(
                  itemCount: _parsedRecords.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (ctx, idx) {
                    final item = _parsedRecords[idx];
                    final name = item['full_name']?.toString() ?? '';
                    final gender = item['gender']?.toString() ?? 'Male';
                    final isFemale = gender == 'Female';
                    final className = item['class_name']?.toString() ?? item['classes']?.toString() ?? '';
                    final phone = item['phone_number']?.toString() ?? item['phone']?.toString() ?? '';
                    final roll = item['roll_number']?.toString() ?? '${idx + 1}';
                    final subject = item['subject']?.toString() ?? '';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: isFemale ? const Color(0xFFFCE7F3) : AppColors.primaryLight,
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1) : '#',
                          style: TextStyle(
                            color: isFemale ? const Color(0xFFBE185D) : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(name, style: AppTypography.labelMedium),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isFemale ? const Color(0xFFFDF2F8) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isFemale ? 'ស្រី' : 'ប្រុស',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isFemale ? const Color(0xFFDB2777) : const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        isStudent
                            ? 'លេខរៀង៖ $roll • ថ្នាក់៖ $className • ទូរស័ព្ទ៖ $phone'
                            : 'មុខវិជ្ជា៖ $subject • ថ្នាក់៖ $className • ទូរស័ព្ទ៖ $phone',
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      ),
                      trailing: const Icon(LucideIcons.check, size: 16, color: AppColors.success),
                    );
                  },
                ),
              ),
            ],
          ],

          const SizedBox(height: 14),

          // Bottom Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (_parsedRecords.isEmpty || _isImporting)
                  ? null
                  : _submitImport,
              icon: _isImporting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(LucideIcons.uploadCloud, size: 18),
              label: Text(
                _isImporting
                    ? 'កំពុងនាំចូលទិន្នន័យ...'
                    : _parsedRecords.isEmpty
                        ? 'សូមទម្លាក់ឯកសារ ឬបិទភ្ជាប់ទិន្នន័យ'
                        : 'នាំចូល ${_parsedRecords.length} នាក់ចូលប្រព័ន្ធ (Import to System)',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor: AppColors.slateBg,
                disabledForegroundColor: AppColors.textSubtle,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
