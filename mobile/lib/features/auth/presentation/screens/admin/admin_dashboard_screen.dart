import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/attendance_session_model.dart';

enum DateFilter { today, week, month }
enum StatusFilter { all, submitted, pending }

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DateFilter _dateFilter = DateFilter.today;
  StatusFilter _statusFilter = StatusFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock sessions matching the current web app
  final List<AttendanceSession> _sessions = [
    AttendanceSession(
      id: 'sess-1',
      className: 'ថ្នាក់ ១០ ក (Grade 10A)',
      subject: 'គណិតវិទ្យា',
      teacherName: 'លោកគ្រូ សុខ សំណាង',
      submitted: true,
      stats: AttendanceStats(total: 36, present: 34, late: 1, absent: 1),
    ),
    AttendanceSession(
      id: 'sess-2',
      className: 'ថ្នាក់ ១០ ខ (Grade 10B)',
      subject: 'រូបវិទ្យា',
      teacherName: 'អ្នកគ្រូ កែវ បុប្ផា',
      submitted: true,
      stats: AttendanceStats(total: 35, present: 32, late: 2, absent: 1),
    ),
    AttendanceSession(
      id: 'sess-3',
      className: 'ថ្នាក់ ១១ ក (Grade 11A)',
      subject: 'ភាសាខ្មែរ',
      teacherName: 'លោកគ្រូ ហេង ពិសិដ្ឋ',
      submitted: false,
      stats: AttendanceStats(total: 38, present: 0, late: 0, absent: 0),
    ),
    AttendanceSession(
      id: 'sess-4',
      className: 'ថ្នាក់ ១១ ខ (Grade 11B)',
      subject: 'គីមីវិទ្យា',
      teacherName: 'អ្នកគ្រូ ចាន់ ស្រីមុំ',
      submitted: true,
      stats: AttendanceStats(total: 34, present: 33, late: 1, absent: 0),
    ),
    AttendanceSession(
      id: 'sess-5',
      className: 'ថ្នាក់ ១២ ក (Grade 12A)',
      subject: 'ជីវវិទ្យា',
      teacherName: 'លោកគ្រូ ជា វណ្ណៈ',
      submitted: false,
      stats: AttendanceStats(total: 40, present: 0, late: 0, absent: 0),
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
          style: GoogleFonts.kantumruyPro(),
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSessionDetailModal(AttendanceSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.className,
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${session.subject} • ${session.teacherName}',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildModalStatItem('វត្តមាន', session.stats.present,
                      const Color(0xFF059669)),
                  _buildModalStatItem('យឺត', session.stats.late,
                      const Color(0xFFD97706)),
                  _buildModalStatItem('អវត្តមាន', session.stats.absent,
                      const Color(0xFFDC2626)),
                  _buildModalStatItem('សរុប', session.stats.total,
                      AppColors.textPrimary),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.kantumruyPro(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ផ្ទាំងគ្រប់គ្រង (Admin Dashboard)',
          style: GoogleFonts.kantumruyPro(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
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
        dateLabel = 'សប្តាហ៍នេះ (25-31 Aug)';
        break;
      case DateFilter.month:
        dateLabel = 'ខែសីហា 2026';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.calendar,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'កាលបរិច្ឆេទត្រួតពិនិត្យ',
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
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
                    color: const Color(0xFFF1F5F9),
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
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.sheet,
                      size: 18, color: AppColors.textSecondary),
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
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              )
            ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.kantumruyPro(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
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

    return Row(
      children: [
        // 1. Submitted Classes Card (Emerald)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
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
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.checkCircle2,
                          color: Colors.white, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$submittedPct%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${_submittedSessions.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF064E3B),
                  ),
                ),
                Text(
                  'ថ្នាក់ដែល Submit រួច',
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Pending Classes Card (Amber)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
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
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.clock,
                          color: Colors.white, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_pendingSessions.length} ថ្នាក់',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${_pendingSessions.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF78350F),
                  ),
                ),
                Text(
                  'ថ្នាក់មិនទាន់រួច (Pending)',
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
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
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.trendingUp,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ស្ថិតិវត្តមានសិស្សទូទាំងសាលា',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'សរុប $_totalStudents នាក់ក្នុងប្រព័ន្ធ',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '$_presentPercentage%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Multi-color Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (_presentPercentage > 0)
                    Expanded(
                      flex: _presentPercentage,
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                  if (_latePercentage > 0)
                    Expanded(
                      flex: _latePercentage,
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                  if (_absentPercentage > 0)
                    Expanded(
                      flex: _absentPercentage,
                      child: Container(color: const Color(0xFFEF4444)),
                    ),
                  if (_totalStudents == 0)
                    Expanded(
                      child: Container(color: const Color(0xFFE2E8F0)),
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
                const Color(0xFF059669),
                const Color(0xFFECFDF5),
              ),
              const SizedBox(width: 8),
              _buildMetricBreakdown(
                'យឺត',
                _totalLate,
                '$_latePercentage%',
                const Color(0xFFD97706),
                const Color(0xFFFFFBEB),
              ),
              const SizedBox(width: 8),
              _buildMetricBreakdown(
                'អវត្តមាន',
                _totalAbsent,
                '$_absentPercentage%',
                const Color(0xFFDC2626),
                const Color(0xFFFEF2F2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBreakdown(
      String label, int count, String pct, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
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
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                text: '$count ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: GoogleFonts.kantumruyPro().fontFamily,
                ),
                children: [
                  TextSpan(
                    text: '($pct)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: color,
                    ),
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
            RichText(
              text: TextSpan(
                text: 'ស្ថានភាពវត្តមានតាមថ្នាក់រៀន ',
                style: GoogleFonts.kantumruyPro(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: '(${_filteredSessions.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Filter Pills (All / Submitted / Pending)
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
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
    return InkWell(
      onTap: () => setState(() => _statusFilter = filter),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.kantumruyPro(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (filter == StatusFilter.submitted
                ? const Color(0xFF059669)
                : filter == StatusFilter.pending
                ? const Color(0xFFD97706)
                : AppColors.primary)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: const Icon(LucideIcons.search,
            size: 18, color: AppColors.textSubtle),
        hintText: 'ស្វែងរកតាមថ្នាក់ មុខវិជ្ជា ឬឈ្មោះគ្រូ...',
        hintStyle: GoogleFonts.kantumruyPro(
          fontSize: 12,
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.users, size: 36, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 8),
            Text(
              'មិនមានទិន្នន័យថ្នាក់ត្រូវនឹងការស្វែងរកទេ',
              style: GoogleFonts.kantumruyPro(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
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
        return InkWell(
          onTap: () => _showSessionDetailModal(item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.className,
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${item.subject})',
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'គ្រូ៖ ${item.teacherName}',
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(' • ',
                              style: TextStyle(color: AppColors.textSubtle)),
                          Text(
                            'វត្តមាន ${item.stats.present}/${item.stats.total} នាក់',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.submitted
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: item.submitted
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.submitted
                            ? LucideIcons.checkCircle2
                            : LucideIcons.clock,
                        size: 12,
                        color: item.submitted
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.submitted ? 'Submit រួច' : 'មិនទាន់ Submit',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: item.submitted
                              ? const Color(0xFF047857)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(LucideIcons.chevronRight,
                    size: 16, color: AppColors.textSubtle),
              ],
            ),
          ),
        );
      },
    );
  }
}