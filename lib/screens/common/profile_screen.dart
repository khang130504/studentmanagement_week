import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studentmanagement_week/services/auth_service.dart';
import '../../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ cá nhân")),
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])),
        child: Center(
          child: GlassCard(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
                    child: Text(user.email![0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 50, color: Colors.white))),
                const SizedBox(height: 20),
                Text(user.email ?? "",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 10),
                Text(
                    "Role: ${user.uid == 'admin_uid' ? 'Admin' : 'Student/Lecturer'}",
                    style:
                        const TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Đăng xuất"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15)),
                  onPressed: () async {
                    await AuthService().signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
