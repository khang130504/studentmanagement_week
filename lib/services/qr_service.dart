import 'dart:math';

class QrService {
  static String generateQRCode() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    String randomPart = String.fromCharCodes(
      Iterable.generate(10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    String timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(6);
    return 'SESSION_$timestamp$randomPart';
  }

  static bool isValidQR(String scannedCode, String expectedCode) {
    return scannedCode == expectedCode;
  }

  static bool isQRStillValid(String qrCode) {
    try {
      String timestampStr = qrCode.split('_')[1];
      int timestamp = int.parse('20$timestampStr'); // giả sử bắt đầu từ 20xx
      DateTime createdTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(createdTime).inMinutes < 10;
    } catch (e) {
      return false;
    }
  }
}
