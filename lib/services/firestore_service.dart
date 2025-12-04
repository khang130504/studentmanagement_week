import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/class_model.dart';
import '../data/models/attendance_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ClassModel>> getClasses() {
    return _db.collection('classes').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ClassModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> createClass(String name, String lecturerId) async {
    await _db.collection('classes').add({
      'name': name,
      'lecturerId': lecturerId,
      'studentIds': [],
    });
  }

  Future<String> createSession(String classId, String qrCode) async {
    var ref = await _db.collection('sessions').add({
      'classId': classId,
      'date': DateTime.now(),
      'qrCode': qrCode,
      'duration': 10,
    });
    return ref.id;
  }

  Future<bool> markAttendance(String sessionId, String studentId) async {
    var snap = await _db
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .where('studentId', isEqualTo: studentId)
        .get();

    if (snap.docs.isNotEmpty) return false; // đã điểm danh

    await _db.collection('attendance').add({
      'sessionId': sessionId,
      'studentId': studentId,
      'timestamp': DateTime.now(),
    });
    return true;
  }

  Stream<List<AttendanceModel>> getAttendanceBySession(String sessionId) {
    return _db
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel(
                  id: doc.id,
                  sessionId: doc['sessionId'],
                  studentId: doc['studentId'],
                  timestamp: (doc['timestamp'] as Timestamp).toDate(),
                ))
            .toList());
  }
  
}
