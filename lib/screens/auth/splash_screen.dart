import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studentmanagement_week/core/constants.dart';
import 'package:studentmanagement_week/data/models/user_model.dart';
import 'package:studentmanagement_week/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation fade-in đẹp
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // ĐÃ FIX: an toàn tuyệt đối

      _navigateToCorrectScreen();
    });
  }

  Future<void> _navigateToCorrectScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final userModel = await AuthService().signInWithCurrentUser(user.uid);

      if (!mounted) return;

      switch (userModel?.role) {
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case UserRole.lecturer:
          Navigator.pushReplacementNamed(context, '/lecturer');
          break;
        case UserRole.student:
          Navigator.pushReplacementNamed(context, '/student');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  AppConstants.logoPath,
                  width: 200,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.school,
                        size: 120, color: Colors.white);
                  },
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),

                const SizedBox(height: 50),

                // Tên app
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Đang tải ứng dụng...",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 80),

                const Text(
                  "© 2025 Student Management System",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
