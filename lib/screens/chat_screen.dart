import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/demo_user.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final DemoUser currentUser;

  const ChatScreen({super.key, required this.currentUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  late final DemoUser _otherUser;

  @override
  void initState() {
    super.initState();

    _otherUser = widget.currentUser.role == 'patient'
        ? DemoUser.doctor()
        : DemoUser.patient();
  }

  String _buildCallId() {
    final participantIds = [widget.currentUser.id, _otherUser.id]..sort();

    return 'call_${participantIds.join('_')}';
  }

  Future<void> _startCall(bool isVideo) async {
    final callId = _buildCallId();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CallScreen(
          currentUser: widget.currentUser,
          otherUser: _otherUser,
          isVideo: isVideo,
          callId: callId,
        ),
      ),
    );
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
