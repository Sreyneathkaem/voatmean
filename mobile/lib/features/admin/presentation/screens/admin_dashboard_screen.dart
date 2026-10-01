import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_typography.dart';
import '../../data/models/attendance_session_model.dart';
import '../../data/services/admin_service.dart';

enum DateFilter { today, week, month }
enum StatusFilter { all, submitted, pending }

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  DateFilter _dateFilter = DateFilter.today;
  StatusFilter _statusFilter = StatusFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final data = await _adminService.getDashboard();
    if (!mounted) return;
    if (data.isNotEmpty) {
      setState(() {
        _sessions.clear();
        for (final row in data) {
          final className = row['class_name']?.toString() ?? 'ថ្នាក់រៀន';
          final teacher = row['teacher_name']?.toString() ?? 'មិនទាន់ចាត់តាំង';
          final subject = (row['major_names'] as String?)?.isNotEmpty == true
              ? row['major_names'].toString()
              : ((row['active_session_name'] as String?)?.isNotEmpty == true
                  ? row['active_session_name'].toString()
                  : 'ទូទៅ');
          final markedToday = int.tryParse('${row['marked_today']}') ?? 0;
          final total = int.tryParse('${row['total_students']}') ?? 0;
          final present = int.tryParse('${row['present_count']}') ?? 0;
          final lateCount = int.tryParse('${row['late_count']}') ?? 0;
          final absent = int.tryParse('${row['absent_count']}') ?? 0;
          _sessions.add(
            AttendanceSession(
              id: row['class_id']?.toString() ?? '',
              className: className,
              subject: subject,
              teacherName: teacher,
              submitted: markedToday > 0 || present > 0,
              stats: AttendanceStats(
                total: total,
                present: present,
                late: lateCount,
                absent: absent,
              ),
            ),
          );
        }
      });
    }
  }

  // Mock sessions matching the web app (fallback)
  final List<AttendanceSession> _sessions = [
    AttendanceSession(
      id: 'sess-1',
      className: 'Grade 10A (ថ្នាក់ ១០ ក)',
      subject: 'គណិតវិទ្យា',
      teacherName: 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)',
      submitted: true,
      stats: AttendanceStats(total: 36, present: 34, late: 1, absent: 1),
    ),
    AttendanceSession(
      id: 'sess-2',
      className: 'Grade 10B (ថ្នាក់ ១០ ខ)',
      subject: 'រូបវិទ្យា',
      teacherName: 'អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)',
      submitted: true,
      stats: AttendanceStats(total: 35, present: 32, late: 2, absent: 1),
    ),
    AttendanceSession(
      id: 'sess-3',
      className: 'Grade 11A (ថ្នាក់ ១១ ក)',
      subject: 'ភាសាខ្មែរ',
      teacherName: 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)',
      submitted: false,
      stats: AttendanceStats(total: 38, present: 0, late: 0, absent: 0),
    ),
    AttendanceSession(
      id: 'sess-4',
      className: 'Grade 11B (ថ្នាក់ ១១ ខ)',
      subject: 'គីមីវិទ្យា',
      teacherName: 'អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)',
      submitted: true,
      stats: AttendanceStats(total: 34, present: 33, late: 1, absent: 0),
    ),
    AttendanceSession(
      id: 'sess-5',
      className: 'Grade 12A (ថ្នាក់ ១២ ក)',
      subject: 'ជីវវិទ្យា',
      teacherName: 'អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)',
      submitted: false,
      stats: AttendanceStats(total: 40, present: 0, late: 0, absent: 0),
    ),
    AttendanceSession(
      id: 'sess-6',
      className: 'Grade 12B (ថ្នាក់ ១២ ខ)',
      subject: 'ភាសាអង់គ្លេស',
      teacherName: 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)',
      submitted: true,
      stats: AttendanceStats(total: 35, present: 33, late: 1, absent: 1),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Calculations ---
  List<AttendanceSession> get _submittedSessions =>
      _sessions.where((s) => s.submitted).toList();

  List<AttendanceSession> get _pendingSessions =>
      _sessions.where((s) => !s.submitted).toList();

  int get _totalStudents =>
      _sessions.fold(0, (acc, s) => acc + s.stats.total);
  int get _totalPresent =>
      _sessions.fold(0, (acc, s) => acc + s.stats.present);
  int get _totalLate =>
      _sessions.fold(0, (acc, s) => acc + s.stats.late);
  int get _totalAbsent =>
      _sessions.fold(0, (acc, s) => acc + s.stats.absent);

  int get _presentPercentage =>
      _totalStudents > 0 ? ((_totalPresent / _totalStudents) * 100).round() : 0;
  int get _latePercentage =>
      _totalStudents > 0 ? ((_totalLate / _totalStudents) * 100).round() : 0;
  int get _absentPercentage =>
      _totalStudents > 0 ? ((_totalAbsent / _totalStudents) * 100).round() : 0;

  List<AttendanceSession> get _filteredSessions {
    return _sessions.where((s) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = s.className.toLowerCase().contains(query) ||
          s.subject.toLowerCase().contains(query) ||
          s.teacherName.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == StatusFilter.all
          ? true
          : _statusFilter == StatusFilter.submitted
              ? s.submitted
              : !s.submitted;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'បានទាញយករបាយការណ៍សង្ខេបវត្តមាន Excel (.xlsx) ជោគជ័យ',
          style: AppTypography.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  DateTime _selectedDate = DateTime.now();

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      helpText: 'ជ្រើសរើសកាលបរិច្ឆេទត្រួតពិនិត្យ',
      cancelText: 'បោះបង់',
      confirmText: 'យល់ព្រម',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'បានជ្រើសរើសកាលបរិច្ឆេទ៖ ${picked.day}/${picked.month}/${picked.year}',
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showSessionDetailModal(AttendanceSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.className, style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context))),
                      const SizedBox(height: 2),
                      Text(
                        'មុខវិជ្ជា៖ ${session.subject} • ${session.teacherName}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSubtleOf(context)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(LucideIcons.x, size: 20, color: AppColors.textSubtleOf(context)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slateBgOf(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildModalStatItem('វត្តមាន', session.stats.present, AppColors.success),
                  _buildModalStatItem('យឺត', session.stats.late, AppColors.warning),
                  _buildModalStatItem('អវត្តមាន', session.stats.absent, AppColors.danger),
                  _buildModalStatItem('សរុប', session.stats.total, AppColors.textPrimaryOf(context)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (!session.submitted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'បានផ្ញើការរំលឹកស្រង់វត្តមានទៅកាន់ ${session.teacherName} ជោគជ័យ',
                              style: AppTypography.bodySmall.copyWith(color: Colors.white),
                            ),
                            backgroundColor: AppColors.warningDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.bellRing, size: 16),
                      label: Text('រំលឹកគ្រូ', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warningDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (!session.submitted) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('បានបើកបញ្ជីសិស្សលម្អិតសម្រាប់ ${session.className}', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.users, size: 16),
                    label: Text('បញ្ជីសិស្ស', style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimaryOf(context))),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.borderOf(context)),
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

  Widget _buildModalStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTypography.displayMedium.copyWith(color: color, fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.captionBold.copyWith(color: AppColors.textSecondaryOf(context)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'ផ្ទាំងគ្រប់គ្រង',
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryOf(context)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderOf(context)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Date Filter & Export Header
            _buildDateFilterHeader(),
            const SizedBox(height: 14),

            // 2. Summary Interactive Cards (Submitted vs Pending)
            _buildSummaryCards(),
            const SizedBox(height: 14),

            // 3. Overall Student Attendance Progress Card
            _buildAttendanceProgressCard(),
            const SizedBox(height: 20),

            // 4. Class Attendance Status Header & Filter Pills
            _buildClassSectionHeader(),
            const SizedBox(height: 12),

            // 5. Search Bar
            _buildSearchBar(),
            const SizedBox(height: 12),

            // 6. Sessions List
            _buildSessionsList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildDateFilterHeader() {
    String dateLabel = '';
    switch (_dateFilter) {
      case DateFilter.today:
        dateLabel = '31 Aug 2026 (ថ្ងៃនេះ)';
        break;
      case DateFilter.week:
        dateLabel = 'សប្តាហ៍នេះ (25 - 31 Aug)';
        break;
      case DateFilter.month:
        dateLabel = 'ខែសីហា 2026';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppColors.cardShadowOf(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: _pickCustomDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightOf(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderOf(context)),
                  ),
                  child: Icon(LucideIcons.calendar, size: 18, color: AppColors.isDark(context) ? const Color(0xFF60A5FA) : AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: _pickCustomDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('កាលបរិច្ឆេទត្រួតពិនិត្យ (ចុចដើម្បីជ្រើស)', style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context))),
                      Text(dateLabel, style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.slateBgOf(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildDateTab('ថ្ងៃនេះ', DateFilter.today),
                      _buildDateTab('សប្តាហ៍នេះ', DateFilter.week),
                      _buildDateTab('ខែនេះ', DateFilter.month),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _exportExcel,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.cardOf(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderOf(context)),
                  ),
                  child: Icon(LucideIcons.sheet, size: 18, color: AppColors.textSecondaryOf(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTab(String label, DateFilter filter) {
    final isSelected = _dateFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _dateFilter = filter),
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cardOf(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected
                  ? (AppColors.isDark(context) ? const Color(0xFF60A5FA) : AppColors.primary)
                  : AppColors.textSecondaryOf(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final submittedPct = _sessions.isNotEmpty
        ? ((_submittedSessions.length / _sessions.length) * 100).round()
        : 0;

    final isSubmittedSelected = _statusFilter == StatusFilter.submitted;
    final isPendingSelected = _statusFilter == StatusFilter.pending;

    return Row(
      children: [
        // 1. Submitted Classes Card (Emerald - Interactive)
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _statusFilter = isSubmittedSelected ? StatusFilter.all : StatusFilter.submitted;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successBgOf(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSubmittedSelected ? AppColors.success : AppColors.successBorderOf(context),
                    width: isSubmittedSelected ? 2 : 1,
                  ),
                  boxShadow: isSubmittedSelected ? AppColors.elevatedShadowOf(context) : AppColors.cardShadowOf(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cardOf(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.successBorderOf(context)),
                          ),
                          child: Text(
                            '$submittedPct%',
                            style: AppTypography.captionBold.copyWith(color: AppColors.successTextOf(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_submittedSessions.length}',
                      style: AppTypography.displayLarge.copyWith(color: AppColors.successTextOf(context), fontSize: 24),
                    ),
                    Text(
                      'ថ្នាក់ Submit រួច (ចុចច្រោះ)',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.successTextOf(context)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Pending Classes Card (Amber - Interactive)
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _statusFilter = isPendingSelected ? StatusFilter.all : StatusFilter.pending;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningBgOf(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isPendingSelected ? AppColors.warning : AppColors.warningBorderOf(context),
                    width: isPendingSelected ? 2 : 1,
                  ),
                  boxShadow: isPendingSelected ? AppColors.elevatedShadowOf(context) : AppColors.cardShadowOf(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.clock, color: Colors.white, size: 20),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cardOf(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warningBorderOf(context)),
                          ),
                          child: Text(
                            '${_pendingSessions.length} ថ្នាក់',
                            style: AppTypography.captionBold.copyWith(color: AppColors.warningTextOf(context)),
                          ),
                        ),
                      ],
                    ),
                const SizedBox(height: 10),
                Text(
                  '${_pendingSessions.length}',
                  style: AppTypography.displayLarge.copyWith(color: AppColors.warningTextOf(context), fontSize: 24),
                ),
                Text(
                  'ថ្នាក់មិនទាន់រួច (Pending)',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.warningTextOf(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
);
  }

  Widget _buildAttendanceProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: AppColors.cardShadowOf(context),
      ),
      child: Column(
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
                      color: AppColors.primaryLightOf(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.trendingUp,
                      size: 18,
                      color: AppColors.isDark(context) ? const Color(0xFF60A5FA) : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ស្ថិតិវត្តមានសិស្សទូទាំងសាលា', style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context))),
                      Text('សរុប $_totalStudents នាក់ក្នុងប្រព័ន្ធ', style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context))),
                    ],
                  ),
                ],
              ),
              Text(
                '$_presentPercentage%',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.isDark(context) ? const Color(0xFF60A5FA) : AppColors.primary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (_presentPercentage > 0)
                    Expanded(
                      flex: _presentPercentage,
                      child: Container(color: AppColors.success),
                    ),
                  if (_latePercentage > 0)
                    Expanded(
                      flex: _latePercentage,
                      child: Container(color: AppColors.warning),
                    ),
                  if (_absentPercentage > 0)
                    Expanded(
                      flex: _absentPercentage,
                      child: Container(color: AppColors.danger),
                    ),
                  if (_totalStudents == 0)
                    Expanded(
                      child: Container(color: AppColors.borderOf(context)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Breakdown Chips
          Row(
            children: [
              _buildMetricBreakdown(
                'វត្តមាន',
                _totalPresent,
                '$_presentPercentage%',
                AppColors.successTextOf(context),
                AppColors.successBgOf(context),
                AppColors.successBorderOf(context),
              ),
              const SizedBox(width: 8),
              _buildMetricBreakdown(
                'យឺត',
                _totalLate,
                '$_latePercentage%',
                AppColors.warningTextOf(context),
                AppColors.warningBgOf(context),
                AppColors.warningBorderOf(context),
              ),
              const SizedBox(width: 8),
              _buildMetricBreakdown(
                'អវត្តមាន',
                _totalAbsent,
                '$_absentPercentage%',
                AppColors.dangerTextOf(context),
                AppColors.dangerBgOf(context),
                AppColors.dangerBorderOf(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBreakdown(
    String label,
    int count,
    String pct,
    Color color,
    Color bg,
    Color border,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.captionBold.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                text: '$count ',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimaryOf(context)),
                children: [
                  TextSpan(
                    text: '($pct)',
                    style: AppTypography.caption.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ស្ថានភាពវត្តមានតាមថ្នាក់រៀន',
              style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLightOf(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_filteredSessions.length} ថ្នាក់',
                style: AppTypography.captionBold.copyWith(
                  color: AppColors.isDark(context) ? const Color(0xFF60A5FA) : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Filter Pills (All / Submitted / Pending)
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.slateBgOf(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusPill('ទាំងអស់', StatusFilter.all),
              _buildStatusPill('Submit រួច', StatusFilter.submitted),
              _buildStatusPill('មិនទាន់ Submit', StatusFilter.pending),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String label, StatusFilter filter) {
    final isSelected = _statusFilter == filter;
    final isDark = AppColors.isDark(context);
    final activeColor = filter == StatusFilter.submitted
        ? AppColors.successTextOf(context)
        : filter == StatusFilter.pending
            ? AppColors.warningTextOf(context)
            : (isDark ? const Color(0xFF60A5FA) : AppColors.primary);

    return InkWell(
      onTap: () => setState(() => _statusFilter = filter),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardOf(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: isSelected && isDark ? Border.all(color: AppColors.borderOf(context)) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? activeColor : AppColors.textSecondaryOf(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryOf(context)),
      decoration: InputDecoration(
        prefixIcon: Icon(LucideIcons.search, size: 18, color: AppColors.textSecondaryOf(context)),
        hintText: 'ស្វែងរកតាមថ្នាក់ មុខវិជ្ជា ឬឈ្មោះគ្រូ...',
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtleOf(context)),
        filled: true,
        fillColor: AppColors.cardOf(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.borderOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_filteredSessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cardOf(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderOf(context)),
          boxShadow: AppColors.cardShadowOf(context),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.users, size: 36, color: AppColors.textSubtleOf(context)),
            const SizedBox(height: 8),
            Text('មិនមានទិន្នន័យថ្នាក់ត្រូវនឹងការស្វែងរកទេ', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryOf(context))),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, index) {
        final item = _filteredSessions[index];
        final isSubmitted = item.submitted;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardOf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderOf(context)),
            boxShadow: AppColors.cardShadowOf(context),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showSessionDetailModal(item),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isSubmitted ? AppColors.success : AppColors.warning,
                        width: 4.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.className,
                                    style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryOf(context)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.slateBgOf(context),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.subject,
                                      style: AppTypography.captionBold.copyWith(color: AppColors.textSecondaryOf(context)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.teacherName,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryOf(context)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(' • ', style: TextStyle(color: AppColors.borderOf(context))),
                                Text(
                                  'វត្តមាន ${item.stats.present}/${item.stats.total} នាក់',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondaryOf(context)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.submitted ? AppColors.successBgOf(context) : AppColors.warningBgOf(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: item.submitted ? AppColors.successBorderOf(context) : AppColors.warningBorderOf(context),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.submitted ? LucideIcons.checkCircle2 : LucideIcons.clock,
                              size: 12,
                              color: item.submitted ? AppColors.successTextOf(context) : AppColors.warningTextOf(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.submitted ? 'Submit រួច' : 'មិនទាន់ Submit',
                              style: AppTypography.captionBold.copyWith(
                                color: item.submitted ? AppColors.successTextOf(context) : AppColors.warningTextOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSecondaryOf(context)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
