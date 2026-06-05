import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_session.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> startCall(CallSession session) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('calls')
          .add(session.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi bắt đầu cuộc gọi: $e');
    }
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
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return CallSession.fromMap(
            snapshot.docs.first.data(),
            snapshot.docs.first.id,
          );
        });
  }

  Stream<CallSession?> listenToCallSession(String docId) {
    return _firestore.collection('calls').doc(docId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CallSession.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }
}
