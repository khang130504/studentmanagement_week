import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studentmanagement_week/widgets/glass_card.dart';

class ManageClassesScreen extends StatefulWidget {
  const ManageClassesScreen({super.key});

  @override
  State<ManageClassesScreen> createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends State<ManageClassesScreen> {
  final TextEditingController _classNameCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String _searchQuery = '';
  String _filterLecturer = 'all'; // all, assigned, unassigned

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  Future<void> _createClass() async {
    final name = _classNameCtrl.text.trim();
    if (name.isEmpty) return;

    await FirebaseFirestore.instance.collection('classes').add({
      'name': name,
      'lecturerId': '',
      'studentIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': currentUserId,
    });

    _classNameCtrl.clear();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Tạo lớp thành công!"), backgroundColor: Colors.green),
    );
  }

  Future<void> _updateClassName(String classId, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sửa tên lớp",
            style: TextStyle(color: Colors.deepPurple)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Tên lớp mới",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child:
                const Text("Cập nhật", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (updated == true && controller.text.trim() != currentName) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .update({'name': controller.text.trim()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Đã cập nhật tên lớp!"),
              backgroundColor: Colors.blue),
        );
      }
    }
  }

  Future<void> _deleteClass(String classId, String className) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xóa lớp học?", style: TextStyle(color: Colors.red)),
        content: Text(
            "Bạn có chắc muốn xóa lớp:\n\"$className\"?\n\nHành động này không thể hoàn tác!"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Đã xóa lớp \"$className\""),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showClassDetail(
      Map<String, dynamic> data, String classId, String className) {
    final studentCount = (data['studentIds'] as List?)?.length ?? 0;
    final lecturerId = data['lecturerId']?.toString() ?? '';
    final hasLecturer = lecturerId.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3))),
              ),
              const SizedBox(height: 20),
              Text(className,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple)),
              const Divider(height: 30),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text("Số sinh viên"),
                subtitle: Text("$studentCount sinh viên"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(hasLecturer ? Icons.school : Icons.person_off,
                    color: hasLecturer ? Colors.green : Colors.orange),
                title: const Text("Giảng viên phụ trách"),
                subtitle:
                    Text(hasLecturer ? "Đã phân công" : "Chưa có giảng viên"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateClassName(classId, className),
                  icon: const Icon(Icons.edit),
                  label: const Text("Sửa tên lớp"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.redAccent
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Quản lý lớp học"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClassDialog(),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text("Thêm lớp"),
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
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm lớp học...",
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchCtrl.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('classes')
                        .orderBy('createdAt', descending: true)
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

                      var classes = snapshot.data!.docs;

                      if (_searchQuery.isNotEmpty) {
                        classes = classes.where((doc) {
                          final name =
                              (doc['name'] as String?)?.toLowerCase() ?? '';
                          return name.contains(_searchQuery);
                        }).toList();
                      }

                      if (_filterLecturer != 'all') {
                        classes = classes.where((doc) {
                          final lecturerId =
                              doc['lecturerId']?.toString() ?? '';
                          return _filterLecturer == 'assigned'
                              ? lecturerId.isNotEmpty
                              : lecturerId.isEmpty;
                        }).toList();
                      }

                      if (classes.isEmpty) {
                        return Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? "Không tìm thấy lớp nào"
                                : "Chưa có lớp học nào\nNhấn + để tạo lớp mới",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final doc = classes[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final String classId = doc.id;
                          final String name = data['name'] ?? 'Không tên';
                          final int studentCount =
                              (data['studentIds'] as List?)?.length ?? 0;
                          final bool hasLecturer =
                              (data['lecturerId']?.toString() ?? '').isNotEmpty;
                          final Color cardColor = _getColorFromName(name);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        cardColor.withOpacity(0.4),
                                        cardColor.withOpacity(0.15)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () =>
                                        _showClassDetail(data, classId, name),
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          cardColor.withOpacity(0.5),
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                    title: Text(name,
                                        style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 6),
                                        Text("Sinh viên: $studentCount người",
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                                hasLecturer
                                                    ? Icons.check_circle
                                                    : Icons.info_outline,
                                                size: 16,
                                                color: hasLecturer
                                                    ? Colors.greenAccent
                                                    : Colors.orangeAccent),
                                            const SizedBox(width: 4),
                                            Text(
                                              hasLecturer
                                                  ? "Đã có giảng viên"
                                                  : "Chưa có GV",
                                              style: TextStyle(
                                                  color: hasLecturer
                                                      ? Colors.greenAccent
                                                      : Colors.orangeAccent,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton(
                                      color: Colors.white,
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                            value: 'edit',
                                            child: Text("Sửa tên")),
                                        const PopupMenuItem(
                                            value: 'delete',
                                            child: Text("Xóa lớp",
                                                style: TextStyle(
                                                    color: Colors.red))),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit')
                                          _updateClassName(classId, name);
                                        if (value == 'delete')
                                          _deleteClass(classId, name);
                                      },
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddClassDialog() {
    _classNameCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tạo lớp học mới",
            style: TextStyle(color: Colors.deepPurple)),
        content: TextField(
          controller: _classNameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "VD: Lập trình di động K14",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: _createClass,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("Tạo lớp", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Lọc lớp học"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text("Tất cả"),
              value: 'all',
              groupValue: _filterLecturer,
              onChanged: (v) => setState(() => _filterLecturer = v!),
            ),
            RadioListTile(
              title: const Text("Đã có giảng viên"),
              value: 'assigned',
              groupValue: _filterLecturer,
              onChanged: (v) => setState(() => _filterLecturer = v!),
            ),
            RadioListTile(
              title: const Text("Chưa có giảng viên"),
              value: 'unassigned',
              groupValue: _filterLecturer,
              onChanged: (v) => setState(() => _filterLecturer = v!),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _classNameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }
}
