import 'package:flutter/material.dart';
import '../models/call_session.dart';
import '../services/call_service.dart';

class IncomingCallDialog extends StatefulWidget {
  final CallSession session;
  final Function(bool) onResponse;

  const IncomingCallDialog({
    super.key,
    required this.session,
    required this.onResponse,
  });

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog> {
  final CallService _callService = CallService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cuộc gọi đến'),
      content: Text(
        '${widget.session.callerName} đang gọi ${widget.session.type}...',
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await _callService.updateCallStatus(
              widget.session.docId,
              'rejected',
            );
            widget.onResponse(false);
          },
          child: const Text('Từ chối'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _callService.updateCallStatus(
              widget.session.docId,
              'accepted',
            );
            widget.onResponse(true);
          },
          child: const Text('Chấp nhận'),
        ),
      ],
    );
  }
}
