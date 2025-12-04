class AttendanceModel {
  final String id;
  final String sessionId;
  final String studentId;
  final DateTime timestamp;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.timestamp,
  });
}
