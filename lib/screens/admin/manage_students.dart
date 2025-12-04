// lib/screens/admin/manage_students_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studentmanagement_week/widgets/glass_card.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
      });
    });
  }

  // Gán sinh viên vào lớp
  Future<void> _assignToClass(String studentId, String studentName) async {
    final classesSnap =
        await FirebaseFirestore.instance.collection('classes').get();
    final classList = classesSnap.docs;

    if (classList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa có lớp nào! Hãy tạo lớp trước.")),
      );
      return;
    }

    String? selectedClassId;
    String? selectedClassName;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Gán lớp cho\n$studentName",
            style: const TextStyle(color: Colors.deepPurple)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: classList.length,
            itemBuilder: (ctx, i) {
              final cls = classList[i];
              final name = cls['name'] as String;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.2),
                  child: Text(name[0],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(name),
                onTap: () {
                  selectedClassId = cls.id;
                  selectedClassName = name;
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );

    if (selectedClassId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .update({'classId': selectedClassId});

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(selectedClassId)
          .update({
        'studentIds': FieldValue.arrayUnion([studentId])
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Đã gán vào lớp: $selectedClassName"),
            backgroundColor: Colors.green),
      );
    }
  }

  // Xóa sinh viên
  Future<void> _deleteStudent(String studentId, String studentName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Xóa sinh viên?"),
        content: Text("Xóa $studentName?\nHành động này không thể hoàn tác!"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Đã xóa $studentName"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Quản lý sinh viên"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm sinh viên...",
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Colors.white70),
                              onPressed: () {
                                _searchCtrl.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'student')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                          child: Text("Lỗi: ${snapshot.error}",
                              style: const TextStyle(color: Colors.white)));
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }

                    var students = snapshot.data!.docs;

                    if (_searchQuery.isNotEmpty) {
                      students = students.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name =
                            (data['name'] as String?)?.toLowerCase() ?? '';
                        final email =
                            (data['email'] as String?)?.toLowerCase() ?? '';
                        return name.contains(_searchQuery) ||
                            email.contains(_searchQuery);
                      }).toList();
                    }

                    if (students.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? "Chưa có sinh viên nào"
                              : "Không tìm thấy sinh viên",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: students.length,
                      itemBuilder: (context, i) {
                        final doc = students[i];
                        final data = doc.data() as Map<String, dynamic>;
                        final String uid = doc.id;
                        final String name = data['name'] ?? 'Không tên';
                        final String email = data['email'] ?? '';
                        final String? classId = data['classId'] as String?;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepPurple.withOpacity(0.3),
                                      Colors.deepPurple.withOpacity(0.1)
                                    ],
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  title: Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  subtitle: Text(email,
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Trạng thái lớp
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: classId == null
                                              ? Colors.red.withOpacity(0.3)
                                              : Colors.green.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          classId == null
                                              ? "Chưa có lớp"
                                              : "Đã có lớp",
                                          style: TextStyle(
                                            color: classId == null
                                                ? Colors.redAccent
                                                : Colors.greenAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      PopupMenuButton(
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.white70),
                                        itemBuilder: (_) => [
                                          PopupMenuItem(
                                            child: const Text("Gán vào lớp"),
                                            onTap: () =>
                                                _assignToClass(uid, name),
                                          ),
                                          PopupMenuItem(
                                            child: const Text("Xóa sinh viên",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                            onTap: () =>
                                                _deleteStudent(uid, name),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
