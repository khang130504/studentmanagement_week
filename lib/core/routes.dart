import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/admin/admin_home.dart';
import '../screens/lecturer/lecturer_home.dart';
import '../screens/student/student_home.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String adminHome = '/admin';
  static const String lecturerHome = '/lecturer';
  static const String studentHome = '/student';

  static final routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    adminHome: (context) => const AdminHome(),
    lecturerHome: (context) => const LecturerHome(),
    studentHome: (context) => const StudentHome(),
  };
}
