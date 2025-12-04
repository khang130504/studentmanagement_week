import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceReportScreen extends StatelessWidget {
  final String sessionId;
  const AttendanceReportScreen({super.key, required this.sessionId});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green.withOpacity(0.4);
      case 'late':
        return Colors.orange.withOpacity(0.4);
      default:
        return Colors.red.withOpacity(0.4);
    }
  }

  // Icon theo trạng thái
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle_outline;
      case 'late':
        return Icons.access_time;
      default:
        return Icons.cancel_outlined;
    }
  }

  // Màu icon
  Color _getIconColor(String status) {
    switch (status) {
      case 'present':
        return Colors.greenAccent;
      case 'late':
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Báo cáo điểm danh"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: "Chia sẻ báo cáo",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Chức năng chia sẻ báo cáo đang phát triển!"),
                  backgroundColor: Colors.indigo,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: "Xuất Excel",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Xuất file Excel sẽ có trong bản cập nhật tới!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance')
                .where('sessionId', isEqualTo: sessionId)
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              // Đang tải
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 5),
                );
              }

              // Lỗi
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off,
                          size: 80, color: Colors.white70),
                      const SizedBox(height: 20),
                      const Text("Không thể tải dữ liệu",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("${snapshot.error}",
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 14)),
                    ],
                  ),
                );
              }

              // Không có sinh viên nào điểm danh
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_alt_outlined,
                          size: 100, color: Colors.white54),
                      const SizedBox(height: 30),
                      const Text(
                        "Chưa có sinh viên điểm danh",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Hãy đợi sinh viên quét mã QR\nhoặc thử làm mới sau vài phút",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, color: Colors.white70),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Quay lại"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              // Thống kê nhanh
              int present = 0, late = 0, absent = 0;
              for (var doc in docs) {
                final status =
                    (doc['status'] as String?)?.toLowerCase() ?? 'absent';
                if (status == 'present')
                  present++;
                else if (status == 'late')
                  late++;
                else
                  absent++;
              }
              final total = docs.length;
              final attendanceRate = total > 0 ? (present / total) * 100 : 0.0;

              return Column(
                children: [
                  // Card tổng kết
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("Tổng kết buổi điểm danh",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatBox("Tổng", total.toString(),
                                Icons.groups_rounded, Colors.cyanAccent),
                            _buildStatBox("Có mặt", present.toString(),
                                Icons.check_circle_rounded, Colors.greenAccent),
                            _buildStatBox("Muộn", late.toString(),
                                Icons.access_time_filled, Colors.orangeAccent),
                            _buildStatBox("Vắng", absent.toString(),
                                Icons.cancel_rounded, Colors.redAccent),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 28),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.amber, width: 1.5),
                          ),
                          child: Text(
                            "Tỷ lệ điểm danh: ${attendanceRate.toStringAsFixed(1)}%",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Danh sách chi tiết
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final status =
                            (data['status'] as String?)?.toLowerCase() ??
                                'absent';
                        final timestamp = data['timestamp'] != null
                            ? (data['timestamp'] as Timestamp).toDate()
                            : DateTime.now();

                        final studentName = data['studentName']
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ==
                                true
                            ? data['studentName'].toString()
                            : "SV ${data['studentId']?.toString().substring(0, 8) ?? 'Unknown'}";

                        final studentEmail =
                            data['studentEmail']?.toString() ?? "Chưa có email";

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getStatusColor(status),
                                  _getStatusColor(status).withOpacity(0.1)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    _getStatusColor(status).withOpacity(0.9),
                                child: Text(
                                  studentName.isNotEmpty
                                      ? studentName[0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                              ),
                              title: Text(
                                studentName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 17),
                              ),
                              subtitle: Text(
                                studentEmail,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_getStatusIcon(status),
                                      color: _getIconColor(status), size: 32),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('HH:mm:ss').format(timestamp),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(timestamp),
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget thống kê nhỏ
  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 42, color: color),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
