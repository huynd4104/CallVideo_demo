import 'package:flutter/material.dart';
import '../models/call_session.dart';
import '../services/call_service.dart';

class IncomingCallDialog extends StatefulWidget {
  final CallSession session;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallDialog({
    super.key,
    required this.session,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog> {
  final CallService _callService = CallService();

  Future<void> _handleAccept() async {
    // Đọc lại document để kiểm tra status
    final currentSession = await _callService.getCall(widget.session.docId);
    if (currentSession?.status == 'ringing') {
      await _callService.updateCallStatus(widget.session.docId, 'accepted');
      widget.onAccept();
    } else {
      // Cuộc gọi đã bị hủy hoặc kết thúc
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuộc gọi không còn khả dụng')),
        );
      }
    }
  }

  Future<void> _handleReject() async {
    await _callService.updateCallStatus(widget.session.docId, 'rejected');
    widget.onReject();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Cuộc gọi đến'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              widget.session.callerName[0],
              style: const TextStyle(fontSize: 32, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.session.callerName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Đang gọi ${widget.session.type == 'video' ? 'video' : 'thoại'} cho bạn...',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        IconButton(
          onPressed: _handleReject,
          icon: const Icon(Icons.call_end, color: Colors.red, size: 36),
        ),
        IconButton(
          onPressed: _handleAccept,
          icon: const Icon(Icons.call, color: Colors.green, size: 36),
        ),
      ],
    );
  }
}
