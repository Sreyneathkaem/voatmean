import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import '../../data/models/admin_models.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final List<StudentModel> _students = [
    StudentModel(
      id: '1',
      studentId: 'STU001',
      name: 'Chan Sreymom',
      nameKhmer: 'ចាន់ ស្រីមុំ',
      gender: 'F',
      phone: '012 111 222',
      currentClass: 'Grade 10A',
      guardianPhone: '012 333 444',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
    ),
    StudentModel(
      id: '2',
      studentId: 'STU002',
      name: 'Heng Piseth',
      nameKhmer: 'ហេង ពិសិដ្ឋ',
      gender: 'M',
      phone: '012 555 666',
      currentClass: 'Grade 10A',
      guardianPhone: '012 777 888',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('គ្រប់គ្រងសិស្ស', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.userPlus, size: 20, color: AppColors.primary)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                hintText: 'ស្វែងរកសិស្ស...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _students.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final student = _students[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(student.avatarUrl),
                      radius: 24,
                    ),
                    title: Text(student.nameKhmer, style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${student.studentId} • ${student.currentClass}', style: const TextStyle(fontSize: 12)),
                        Text('Tel: ${student.phone}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
