import 'dart:async';
import 'package:flutter/material.dart';
import '../models/demo_user.dart';
import '../services/call_service.dart';
import 'call_screen.dart';

class OutgoingCallScreen extends StatefulWidget {
  final DemoUser currentUser;
  final DemoUser otherUser;
  final bool isVideo;
  final String callDocId;

  const OutgoingCallScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
    required this.isVideo,
    required this.callDocId,
  });

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  final CallService _callService = CallService();
  StreamSubscription? _subscription;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _listenToCallStatus();
  }

  void _listenToCallStatus() {
    _subscription = _callService.listenToCallSession(widget.callDocId).listen((
      session,
    ) {
      if (session == null || !mounted || _isNavigated) return;

      if (session.status == 'accepted') {
        _isNavigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CallScreen(
              currentUser: widget.currentUser,
              otherUser: widget.otherUser,
              isVideo: widget.isVideo,
              callId: widget.callDocId,
              callDocId: widget.callDocId,
            ),
          ),
        );
      } else if (session.status == 'rejected' ||
          session.status == 'cancelled' ||
          session.status == 'ended') {
        _isNavigated = true;
        String message = 'Cuộc gọi đã kết thúc';
        if (session.status == 'rejected') message = 'Cuộc gọi bị từ chối';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _cancelCall() async {
    await _callService.updateCallStatus(widget.callDocId, 'cancelled');
    if (mounted && !_isNavigated) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const Spacer(),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                widget.otherUser.name[0],
                style: const TextStyle(fontSize: 48, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.otherUser.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang gọi ${widget.isVideo ? 'video' : 'thoại'}...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton(
                onPressed: _cancelCall,
                backgroundColor: Colors.red,
                child: const Icon(
                  Icons.call_end,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
