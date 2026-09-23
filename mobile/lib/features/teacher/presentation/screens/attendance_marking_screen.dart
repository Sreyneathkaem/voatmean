import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';

enum AttendanceStatus { present, late, absent }

class AttendanceMarkingScreen extends StatefulWidget {
  final String grade;
  final String subject;

  const AttendanceMarkingScreen({
    super.key,
    required this.grade,
    required this.subject,
  });

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  final List<Map<String, dynamic>> _students = [
    {'id': '1', 'name': 'Sok Samnang', 'nameKhmer': 'សុខ សំណាង', 'gender': 'M', 'status': AttendanceStatus.present},
    {'id': '2', 'name': 'Keo Bopha', 'nameKhmer': 'កែវ បុប្ផា', 'gender': 'F', 'status': AttendanceStatus.present},
    {'id': '3', 'name': 'Chan Sreymom', 'nameKhmer': 'ចាន់ ស្រីមុំ', 'gender': 'F', 'status': AttendanceStatus.present},
    {'id': '4', 'name': 'Heng Piseth', 'nameKhmer': 'ហេង ពិសិដ្ឋ', 'gender': 'M', 'status': AttendanceStatus.present},
    {'id': '5', 'name': 'Chea Vannak', 'nameKhmer': 'ជា វណ្ណៈ', 'gender': 'M', 'status': AttendanceStatus.present},
  ];

  void _updateStatus(int index, AttendanceStatus status) {
    setState(() {
      _students[index]['status'] = status;
    });
  }

  void _submitAttendance() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('បញ្ជូនវត្តមាន?', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
        content: const Text('តើអ្នកប្រាកដថាបានត្រួតពិនិត្យវត្តមានសិស្សទាំងអស់រួចរាល់?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ត្រួតពិនិត្យឡើងវិញ')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('វត្តមានត្រូវបានរក្សាទុកដោយជោគជ័យ'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('បញ្ជូន'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _students.where((s) => s['status'] == AttendanceStatus.present).length;
    int lateCount = _students.where((s) => s['status'] == AttendanceStatus.late).length;
    int absentCount = _students.where((s) => s['status'] == AttendanceStatus.absent).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.grade, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.subject, style: GoogleFonts.kantumruyPro(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.search, size: 20)),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBar(presentCount, lateCount, absentCount),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _students.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final student = _students[index];
                return _buildStudentCard(index, student);
              },
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(int p, int l, int a) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('វត្តមាន', p, const Color(0xFF10B981)),
          _buildSummaryItem('យឺត', l, const Color(0xFFF59E0B)),
          _buildSummaryItem('អវត្តមាន', a, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label: ', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSecondary)),
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  Widget _buildStudentCard(int index, Map<String, dynamic> student) {
    final status = student['status'] as AttendanceStatus;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              student['gender'] == 'F' ? LucideIcons.userRound : LucideIcons.user,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['nameKhmer'], style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(student['name'], style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Row(
            children: [
              _buildStatusBtn(index, AttendanceStatus.present, 'វ', const Color(0xFF10B981), status == AttendanceStatus.present),
              const SizedBox(width: 6),
              _buildStatusBtn(index, AttendanceStatus.late, 'យ', const Color(0xFFF59E0B), status == AttendanceStatus.late),
              const SizedBox(width: 6),
              _buildStatusBtn(index, AttendanceStatus.absent, 'អ', const Color(0xFFEF4444), status == AttendanceStatus.absent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBtn(int index, AttendanceStatus status, String label, Color color, bool isSelected) {
    return InkWell(
      onTap: () => _updateStatus(index, status),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.kantumruyPro(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text('រក្សាទុក និងបញ្ជូនវត្តមាន', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
