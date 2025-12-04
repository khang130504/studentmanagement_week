import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'manage_classes.dart';
import 'manage_students.dart';
import 'manage_lecturers.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Text("Đăng xuất", style: TextStyle(color: Colors.deepPurple)),
        content: const Text("Bạn có chắc muốn đăng xuất khỏi tài khoản Admin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text("Đăng xuất", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Quản trị viên"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.logout, size: 28),
              tooltip: "Đăng xuất",
              onPressed: () => _signOut(context),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Chào mừng Admin!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Chọn chức năng bạn muốn quản lý",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 50),

                _buildAdminCard(
                  context: context,
                  title: "Quản lý lớp học",
                  icon: Icons.class_,
                  colors: [Colors.deepPurple, Colors.indigo],
                  gradientStart: Alignment.topLeft,
                  gradientEnd: Alignment.bottomRight,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageClassesScreen()),
                  ),
                ),
                const SizedBox(height: 20),

                _buildAdminCard(
                  context: context,
                  title: "Quản lý sinh viên",
                  icon: Icons.people_alt,
                  colors: [Colors.teal, Colors.cyan],
                  gradientStart: Alignment.topRight,
                  gradientEnd: Alignment.bottomLeft,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageStudentsScreen()),
                  ),
                ),
                const SizedBox(height: 20),

                _buildAdminCard(
                  context: context,
                  title: "Quản lý giảng viên",
                  icon: Icons.school,
                  colors: [Colors.orange, Colors.deepOrange],
                  gradientStart: Alignment.topLeft,
                  gradientEnd: Alignment.bottomRight,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageLecturersScreen()),
                  ),
                ),

                const Spacer(),

                const Text(
                  "Student Management System © 2025",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> colors,
    required Alignment gradientStart,
    required Alignment gradientEnd,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: colors.map((c) => c.withOpacity(0.8)).toList(),
            begin: gradientStart,
            end: gradientEnd,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Nội dung
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Icon lớn
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 3),
                    ),
                    child: Icon(icon, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 24),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Nhấn để vào quản lý",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // Mũi tên
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
