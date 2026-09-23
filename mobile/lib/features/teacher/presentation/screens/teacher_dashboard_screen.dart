import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'attendance_marking_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('កាលវិភាគបង្រៀន', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            Text('ថ្នាក់រៀនថ្ងៃនេះ', style: GoogleFonts.kantumruyPro(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildClassCard(
              context,
              grade: 'Grade 10A',
              gradeKhmer: 'ថ្នាក់ ១០ ក',
              subject: 'Mathematics',
              time: '08:00 - 09:30 AM',
              room: 'Room 302',
              studentCount: 36,
            ),
            const SizedBox(height: 12),
            _buildClassCard(
              context,
              grade: 'Grade 12A',
              gradeKhmer: 'ថ្នាក់ ១២ ក',
              subject: 'Advanced Mathematics',
              time: '10:00 - 11:30 AM',
              room: 'Room 501',
              studentCount: 40,
              isCompleted: true,
            ),
            const SizedBox(height: 24),
            Text('ថ្នាក់រៀនផ្សេងទៀត', style: GoogleFonts.kantumruyPro(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            _buildSimpleClassTile(
              grade: 'Grade 11B',
              subject: 'Mathematics',
              schedule: 'Mon, Wed, Fri',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'សួស្តី, លោកគ្រូ សុខ សំណាង!',
                  style: GoogleFonts.kantumruyPro(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'ថ្ងៃនេះអ្នកមាន ២ ថ្នាក់សម្រាប់បង្រៀន។',
                  style: GoogleFonts.kantumruyPro(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.calendarCheck, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String grade,
    required String gradeKhmer,
    required String subject,
    required String time,
    required String room,
    required int studentCount,
    bool isCompleted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(grade, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(gradeKhmer, style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.emeraldBg : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isCompleted ? 'បានស្រង់រួច' : 'កំពុងបង្រៀន',
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.emeraldIcon : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildIconInfo(LucideIcons.book, subject),
              const SizedBox(width: 16),
              _buildIconInfo(LucideIcons.clock, time),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildIconInfo(LucideIcons.mapPin, room),
              const SizedBox(width: 16),
              _buildIconInfo(LucideIcons.users, '$studentCount នាក់'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceMarkingScreen(
                      grade: grade,
                      subject: subject,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.white : AppColors.primary,
                foregroundColor: isCompleted ? AppColors.textPrimary : Colors.white,
                elevation: 0,
                side: isCompleted ? const BorderSide(color: AppColors.border) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                isCompleted ? 'មើលវត្តមានឡើងវិញ' : 'ស្រង់វត្តមានសិស្ស',
                style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSubtle),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSimpleClassTile({required String grade, required String subject, required String schedule}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.bookOpen, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(grade, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subject, style: GoogleFonts.kantumruyPro(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(schedule, style: const TextStyle(fontSize: 10, color: AppColors.textSubtle)),
        ],
      ),
    );
  }
}
