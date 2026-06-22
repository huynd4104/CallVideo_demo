import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import '../models/demo_user.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final DemoUser currentUser;
  final DemoUser otherUser;
  final bool isVideo;
  final String callId;
  final String callDocId;

  const CallScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
    required this.isVideo,
    required this.callId,
    required this.callDocId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  bool _isEnded = false;
  final JitsiMeet _jitsiMeet = JitsiMeet();
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _startJitsiCall();
  }

  Future<void> _startJitsiCall() async {
    debugPrint('=== JITSI CALL SCREEN ===');
    debugPrint('Room ID / Call ID: ${widget.callId}');
    debugPrint('Current User ID: ${widget.currentUser.id} (Name: ${widget.currentUser.name})');
    debugPrint('Other User ID: ${widget.otherUser.id} (Name: ${widget.otherUser.name})');
    debugPrint('Is Video Call: ${widget.isVideo}');
    debugPrint('========================');

    var options = JitsiMeetConferenceOptions(
      serverURL: "https://meet.jit.si",
      room: widget.callId,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": !widget.isVideo,
      },
      featureFlags: {
        "welcomepage.enabled": false,
        "prejoinPage.enabled": false,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: widget.currentUser.name,
        email: "",
      ),
    );

    var listener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        debugPrint("Conference joined: $url");
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
      },
      conferenceTerminated: (url, error) {
        debugPrint("Conference terminated: $url, error: $error");
        _endCall();
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );

    try {
      await _jitsiMeet.join(options, listener);
    } catch (e) {
      debugPrint("Error joining Jitsi conference: $e");
      _endCall();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _endCall() async {
    if (_isEnded) return;
    _isEnded = true;
    try {
      await _callService.updateCallStatus(widget.callDocId, 'ended');
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
  }

  @override
  void dispose() {
    _endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              _isConnecting ? 'Đang kết nối cuộc gọi...' : 'Cuộc gọi đang diễn ra...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Phòng: ${widget.callId}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _endCall();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Thoát'),
            )
          ],
        ),
      ),
    );
  }
}
