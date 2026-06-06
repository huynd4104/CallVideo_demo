import 'dart:async';
import 'package:flutter/material.dart';

import '../models/call_session.dart';
import '../models/chat_message.dart';
import '../models/demo_user.dart';
import '../services/call_service.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import 'call_screen.dart';
import 'incoming_call_dialog.dart';
import 'outgoing_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final DemoUser currentUser;

  const ChatScreen({super.key, required this.currentUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();
  StreamSubscription? _incomingCallSubscription;
  bool _isShowingIncomingDialog = false;
  String? _lastCallDocId;

  late final DemoUser _otherUser;

  @override
  void initState() {
    super.initState();

    _otherUser = widget.currentUser.role == 'patient'
        ? DemoUser.doctor()
        : DemoUser.patient();

    _listenToIncomingCalls();
  }

  void _listenToIncomingCalls() {
    _incomingCallSubscription = _callService
        .listenToIncomingCall(widget.currentUser.id)
        .listen((session) {
          if (session == null || !mounted) return;
          if (_isShowingIncomingDialog) return;
          if (_lastCallDocId == session.docId) return;

          _showIncomingCallDialog(session);
        });
  }

  void _showIncomingCallDialog(CallSession session) {
    _isShowingIncomingDialog = true;
    _lastCallDocId = session.docId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => IncomingCallDialog(
        session: session,
        onAccept: () {
          _isShowingIncomingDialog = false;
          Navigator.pop(dialogContext); // Đóng dialog bằng dialogContext
          
          // Tránh xung đột hiệu ứng (transition) giữa đóng dialog và mở màn hình call
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.push(
                context, // Sử dụng context của ChatScreen (ngoài) để push CallScreen
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    currentUser: widget.currentUser,
                    otherUser: DemoUser(
                      id: session.callerId,
                      name: session.callerName,
                      role: widget.currentUser.role == 'patient'
                          ? 'doctor'
                          : 'patient',
                    ),
                    isVideo: session.type == 'video',
                    callId: session.docId,
                    callDocId: session.docId,
                  ),
                ),
              );
            }
          });
        },
        onReject: () {
          _isShowingIncomingDialog = false;
          Navigator.pop(dialogContext); // Đóng dialog bằng dialogContext
        },
      ),
    );
  }

  Future<void> _startCall(bool isVideo) async {
    final session = CallSession(
      callId: '', // Sẽ dùng docId sau khi tạo
      callerId: widget.currentUser.id,
      callerName: widget.currentUser.name,
      receiverId: _otherUser.id,
      receiverName: _otherUser.name,
      type: isVideo ? 'video' : 'audio',
      status: 'ringing',
    );

    final docId = await _callService.createCall(session);

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OutgoingCallScreen(
          currentUser: widget.currentUser,
          otherUser: _otherUser,
          isVideo: isVideo,
          callDocId: docId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _incomingCallSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherRoleLabel = _otherUser.role == 'doctor' ? 'Bác sĩ' : 'Bệnh nhân';

    return Scaffold(
      appBar: AppBar(
        title: Text('${_otherUser.name} ($otherRoleLabel)'),
        actions: [
          IconButton(
            tooltip: 'Gọi thoại',
            icon: const Icon(Icons.call),
            onPressed: () => _startCall(false),
          ),
          IconButton(
            tooltip: 'Gọi video',
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall(true),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(
                widget.currentUser.id,
                _otherUser.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi tải tin nhắn: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có tin nhắn.\nHãy bắt đầu cuộc trò chuyện.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == widget.currentUser.id,
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            onSendMessage: (content) async {
              final trimmedContent = content.trim();

              if (trimmedContent.isEmpty) {
                return;
              }

              await _chatService.sendMessage(
                ChatMessage(
                  senderId: widget.currentUser.id,
                  senderName: widget.currentUser.name,
                  receiverId: _otherUser.id,
                  content: trimmedContent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
