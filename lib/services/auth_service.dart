import 'package:firebase_auth/firebase_auth.dart';
import '../models/demo_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DemoUser? _currentUser;

  DemoUser? get currentUser => _currentUser;

  Future<void> signInAnonymously(DemoUser user) async {
    try {
      await _auth.signInAnonymously();
      _currentUser = user;
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      throw Exception('Lỗi đăng xuất: $e');
    }
  }
}
