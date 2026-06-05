import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../config/zego_config.dart';
import '../models/demo_user.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final DemoUser currentUser;
  final DemoUser otherUser;
  final bool isVideo;
  final String callId;
  final String? callDocId;

  const CallScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
    required this.isVideo,
    required this.callId,
    this.callDocId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();

  @override
  void dispose() {
    final documentId = widget.callDocId;

    if (documentId != null) {
      _callService.updateCallStatus(documentId, 'ended');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.isVideo
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: ZegoConfig.appId,
          appSign: ZegoConfig.appSign,
          userID: widget.currentUser.id,
          userName: widget.currentUser.name,
          callID: widget.callId,
          config: config,
        ),
      ),
    );
  }
}
