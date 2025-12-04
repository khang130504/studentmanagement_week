class SessionModel {
  final String id;
  final String classId;
  final DateTime date;
  final String qrCode;
  final Duration duration; // phút

  SessionModel({
    required this.id,
    required this.classId,
    required this.date,
    required this.qrCode,
    this.duration = const Duration(minutes: 10),
  });
}
