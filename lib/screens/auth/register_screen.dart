import 'package:flutter/material.dart';
import 'package:studentmanagement_week/data/models/user_model.dart';
import 'package:studentmanagement_week/services/auth_service.dart';
import 'package:studentmanagement_week/widgets/custom_textfield.dart';
import 'package:studentmanagement_week/widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  UserRole _role = UserRole.student;

  final _auth = AuthService();
  bool _isLoading = false;

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (name.isEmpty) {
      _showSnackBar("Vui lòng nhập họ tên");
      return;
    }
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _showSnackBar("Email không hợp lệ");
      return;
    }
    if (password.length < 6) {
      _showSnackBar("Mật khẩu phải ít nhất 6 ký tự");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.register(email, password, name, _role);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công! Chào mừng bạn "),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      String errorMsg = "Đăng ký thất bại";
      if (e is String)
        errorMsg = e;
      else if (e.toString().contains('email-already-in-use'))
        errorMsg = "Email này đã được sử dụng";
      else if (e.toString().contains('weak-password'))
        errorMsg = "Mật khẩu quá yếu";
      _showSnackBar(errorMsg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, size: 80, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Tạo tài khoản mới",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text("Tham gia hệ thống điểm danh ngay hôm nay!",
                          style:
                              TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 32),

                      CustomTextField(
                          hint: "Họ và tên",
                          icon: Icons.person_outline,
                          controller: _nameCtrl),
                      const SizedBox(height: 16),
                      CustomTextField(
                          hint: "Email",
                          icon: Icons.email_outlined,
                          controller: _emailCtrl),
                      const SizedBox(height: 16),
                      CustomTextField(
                          hint: "Mật khẩu (ít nhất 6 ký tự)",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          controller: _passCtrl),
                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<UserRole>(
                            value: _role,
                            dropdownColor: Colors.deepPurple[700],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.white70),
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(
                                  switch (role) {
                                    UserRole.admin => " Quản trị viên",
                                    UserRole.lecturer => " Giảng viên",
                                    UserRole.student => " Sinh viên",
                                  },
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _role = val!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () =>
                                  _register(), 
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2)),
                                    SizedBox(width: 16),
                                    Text("Đang tạo tài khoản...",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white)),
                                  ],
                                )
                              : const Text("Đăng ký ngay",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Đã có tài khoản? Đăng nhập",
                            style: TextStyle(color: Colors.white70)),
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
