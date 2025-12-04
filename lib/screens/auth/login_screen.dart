import 'package:flutter/material.dart';
import 'package:studentmanagement_week/data/models/user_model.dart';
import 'package:studentmanagement_week/services/auth_service.dart';
import 'package:studentmanagement_week/widgets/custom_textfield.dart';
import 'package:studentmanagement_week/widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showError("Vui lòng nhập email hợp lệ");
      return;
    }
    if (password.isEmpty) {
      _showError("Vui lòng nhập mật khẩu");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signIn(email, password);
      if (!mounted) return;

      switch (user!.role) {
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case UserRole.lecturer:
          Navigator.pushReplacementNamed(context, '/lecturer');
          break;
        case UserRole.student:
          Navigator.pushReplacementNamed(context, '/student');
          break;
      }
    } catch (e) {
      String msg = "Đăng nhập thất bại";
      if (e is String) {
        msg = e;
      } else if (e.toString().contains('invalid-credential') ||
          e.toString().contains('wrong-password')) {
        msg = "Sai email hoặc mật khẩu";
      } else if (e.toString().contains('user-not-found')) {
        msg = "Tài khoản không tồn tại";
      }
      _showError(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/logo.png", height: 100),
                      const SizedBox(height: 24),
                      const Text("Chào mừng trở lại!",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text("Đăng nhập để tiếp tục",
                          style:
                              TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 40),

                      CustomTextField(
                          hint: "Email",
                          icon: Icons.email_outlined,
                          controller: _emailCtrl),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _passCtrl,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Mật khẩu",
                            hintStyle: const TextStyle(color: Colors.white60),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 10,
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3)),
                                    SizedBox(width: 16),
                                    Text("Đang đăng nhập...",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                  ],
                                )
                              : const Text("Đăng nhập",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text("Chưa có tài khoản? Đăng ký ngay",
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
