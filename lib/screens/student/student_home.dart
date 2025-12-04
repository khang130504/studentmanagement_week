import 'package:flutter/material.dart';
import 'package:studentmanagement_week/screens/student/scan_qr_screen.dart';
import 'package:studentmanagement_week/screens/student/attendance_history.dart';
import 'package:studentmanagement_week/screens/common/profile_screen.dart';
import 'package:studentmanagement_week/widgets/glass_card.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: const Text("Sinh viên"),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GlassCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child:
                            Icon(Icons.person, size: 35, color: Colors.white)),
                    title: const Text("Chào mừng quay lại!",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    subtitle: const Text("Sẵn sàng điểm danh hôm nay?",
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                        child: _buildMenuCard(
                            context,
                            "Điểm danh QR",
                            Icons.qr_code_scanner,
                            Colors.blue,
                            const ScanQRScreen())),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildMenuCard(
                            context,
                            "Lịch sử điểm danh",
                            Icons.history,
                            Colors.green,
                            const AttendanceHistoryScreen())),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMenuCard(context, "Hồ sơ cá nhân", Icons.account_circle,
                    Colors.orange, const ProfileScreen(),
                    fullWidth: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, Widget page,
      {bool fullWidth = false}) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: GlassCard(
        child: Column(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
