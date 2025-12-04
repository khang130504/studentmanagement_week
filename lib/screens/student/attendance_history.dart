import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String studentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử điểm danh")),
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('attendance')
              .where('studentId', isEqualTo: studentId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final records = snapshot.data!.docs;

            if (records.isEmpty) {
              return const Center(
                  child: Text("Chưa có buổi điểm danh nào",
                      style: TextStyle(fontSize: 18, color: Colors.white70)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (ctx, i) {
                final record = records[i];
                final timestamp = (record['timestamp'] as Timestamp).toDate();

                return GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle,
                        color: Colors.green, size: 40),
                    title: Text("Buổi học ID: ${record['sessionId']}",
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                        "Ngày: ${timestamp.day}/${timestamp.month}/${timestamp.year} - ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.white70)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
