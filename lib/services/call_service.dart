import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_session.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createCall(CallSession session) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('calls')
          .add(session.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi tạo cuộc gọi: $e');
    }
  }

  Future<CallSession?> getCall(String docId) async {
    final doc = await _firestore.collection('calls').doc(docId).get();
    if (!doc.exists) return null;
    return CallSession.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateCallStatus(String docId, String status) async {
    try {
      await _firestore.collection('calls').doc(docId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái cuộc gọi: $e');
    }
  }

  Stream<CallSession?> listenToIncomingCall(String currentUserId) {
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          // Trả về cuộc gọi mới nhất
          final doc = snapshot.docs.first;
          return CallSession.fromMap(doc.data(), doc.id);
        });
  }

  Stream<CallSession?> listenToCallSession(String docId) {
    return _firestore.collection('calls').doc(docId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CallSession.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }
}
