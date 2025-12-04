enum UserRole { admin, lecturer, student }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? classId;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.classId,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'classId': classId,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    final String roleStr = (map['role'] as String?)?.toLowerCase() ?? 'student';

    UserRole userRole = UserRole.student;
    if (roleStr == 'admin') userRole = UserRole.admin;
    if (roleStr == 'lecturer') userRole = UserRole.lecturer;
    if (roleStr == 'student') userRole = UserRole.student;

    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: userRole,
      classId: map['classId'] as String?,
    );
  }
}
