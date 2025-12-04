import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = result.user!.uid;

      DocumentSnapshot snap = await _db.collection('users').doc(uid).get();

      if (!snap.exists || snap.data() == null) {
        throw FirebaseAuthException(
          code: 'user-data-missing',
          message: 'Tài khoản chưa được khởi tạo đầy đủ. Vui lòng đăng ký lại.',
        );
      }

      return UserModel.fromMap(uid, snap.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Tài khoản không tồn tại.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Sai mật khẩu hoặc tài khoản không hợp lệ.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị khóa.';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều lần thử. Vui lòng đợi một lúc.';
          break;
        default:
          message = 'Lỗi đăng nhập: ${e.message}';
      }
      throw message;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> register(
      String email, String password, String name, UserRole role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = result.user!.uid;

      final newUser = UserModel(
        uid: uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
      );

      await _db.collection('users').doc(uid).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Mật khẩu quá yếu (ít nhất 6 ký tự).';
          break;
        case 'email-already-in-use':
          message = 'Email này đã được sử dụng.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        default:
          message = 'Lỗi đăng ký: ${e.message}';
      }
      throw message;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> signInWithCurrentUser(String uid) async {
    try {
      final snap = await _db.collection('users').doc(uid).get();
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(uid, snap.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
