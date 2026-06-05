import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/demo_user.dart';
import 'chat_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  RoleSelectionScreen({super.key});

  Future<void> _login(BuildContext context, DemoUser user) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await _authService.signInAnonymously(user);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(currentUser: user)),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CareBridge')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _login(context, DemoUser.patient()),
              child: const Text('Đăng nhập với vai trò Bệnh nhân'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context, DemoUser.doctor()),
              child: const Text('Đăng nhập với vai trò Bác sĩ'),
            ),
          ],
        ),
      ),
    );
  }
}
