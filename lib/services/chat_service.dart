import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getConversationId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage(ChatMessage message) async {
    try {
      String conversationId = getConversationId(
        message.senderId,
        message.receiverId,
      );

      // Update conversation document
      await _firestore.collection('conversations').doc(conversationId).set({
        'participants': [message.senderId, message.receiverId],
        'lastMessage': message.content,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add message to subcollection
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      throw Exception('Lỗi gửi tin nhắn: $e');
    }
  }

  Stream<List<ChatMessage>> getMessages(String userId1, String userId2) {
    String conversationId = getConversationId(userId1, userId2);
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data()))
              .toList();
        });
  }
}
