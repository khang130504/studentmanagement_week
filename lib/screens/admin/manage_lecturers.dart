import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studentmanagement_week/widgets/glass_card.dart';

class ManageLecturersScreen extends StatefulWidget {
  const ManageLecturersScreen({super.key});

  @override
  State<ManageLecturersScreen> createState() => _ManageLecturersScreenState();
}

class _ManageLecturersScreenState extends State<ManageLecturersScreen> {
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

  Future<void> _assignLecturerToClass(String lecturerId, String lecturerName) async {
    final classesSnap = await FirebaseFirestore.instance.collection('classes').get();
    final classList = classesSnap.docs;

    if (classList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa có lớp học nào để gán!")),
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
        title: Text("Gán lớp cho giảng viên\n$lecturerName",
            style: const TextStyle(color: Colors.deepOrange)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: classList.length,
            itemBuilder: (ctx, i) {
              final cls = classList[i];
              final name = cls['name'] as String;
              final currentLecturerId = cls['lecturerId'] as String? ?? '';
              final isAssigned = currentLecturerId.isNotEmpty;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: Text(name[0],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(name),
                trailing: isAssigned
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                subtitle: isAssigned
                    ? const Text("Đã có GV", style: TextStyle(fontSize: 11))
                    : null,
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
          .collection('classes')
          .doc(selectedClassId)
          .update({'lecturerId': lecturerId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Đã gán GV $lecturerName vào lớp $selectedClassName"),
            backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Quản lý giảng viên"),
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
                      hintText: "Tìm kiếm giảng viên...",
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white70),
                              onPressed: () => _searchCtrl.clear(),
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
                      .where('role', isEqualTo: 'lecturer')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Lỗi: ${snapshot.error}",
                          style: const TextStyle(color: Colors.white)));
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.white));
                    }

                    var lecturers = snapshot.data!.docs;

                    if (_searchQuery.isNotEmpty) {
                      lecturers = lecturers.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] as String?)?.toLowerCase() ?? '';
                        final email = (data['email'] as String?)?.toLowerCase() ?? '';
                        return name.contains(_searchQuery) || email.contains(_searchQuery);
                      }).toList();
                    }

                    if (lecturers.isEmpty) {
                      return const Center(
                        child: Text(
                          "Chưa có giảng viên nào",
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: lecturers.length,
                      itemBuilder: (context, i) {
                        final doc = lecturers[i];
                        final data = doc.data() as Map<String, dynamic>;
                        final String uid = doc.id;
                        final String name = data['name'] ?? 'Không tên';
                        final String email = data['email'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.withOpacity(0.4),
                                      Colors.deepOrange.withOpacity(0.1)
                                    ],
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                                      style: const TextStyle(color: Colors.white70)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.assignment_ind,
                                        color: Colors.amber),
                                    onPressed: () => _assignLecturerToClass(uid, name),
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