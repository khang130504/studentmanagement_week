import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class CreateSessionScreen extends StatefulWidget {
  final String classId;
  const CreateSessionScreen({super.key, required this.classId});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  String? sessionCode;
  bool loading = false;
  Timer? timer;
  int secondsLeft = 600; 

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> createQR() async {
    if (sessionCode != null) return;

    setState(() => loading = true);

    final code = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final newCode = code.padLeft(6, '0');

    await FirebaseFirestore.instance.collection('sessions').add({
      'classId': widget.classId,
      'code': newCode,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt':
          Timestamp.fromDate(DateTime.now().add(Duration(minutes: 10))),
    });

    setState(() {
      sessionCode = newCode;
      loading = false;
    });

    // Bắt đầu đếm ngược
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        t.cancel();
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  String get timerText =>
      "${(secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(secondsLeft % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Tạo mã điểm danh"),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)])),
        child: SafeArea(
          child: Center(
            child: sessionCode == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner,
                          size: 100, color: Colors.white),
                      SizedBox(height: 30),
                      Text("Tạo mã QR điểm danh",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text("Hiệu lực 10 phút",
                          style:
                              TextStyle(fontSize: 18, color: Colors.white70)),
                      SizedBox(height: 50),
                      ElevatedButton.icon(
                        onPressed: loading ? null : createQR,
                        icon: loading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white))
                            : Icon(Icons.qr_code_2, size: 30),
                        label: Text(loading ? "Đang tạo..." : "TẠO MÃ NGAY",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Còn lại $timerText",
                          style: TextStyle(
                              fontSize: 36,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 20)
                            ]),
                        child: Column(
                          children: [
                            Image.network(
                                "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=$sessionCode",
                                width: 300,
                                height: 300),
                            SizedBox(height: 20),
                            SelectableText(sessionCode!,
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace')),
                            Text("Sinh viên quét mã này để điểm danh",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.check_circle),
                          label: Text("Hoàn thành"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16))),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
