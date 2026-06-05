import 'package:cloud_firestore/cloud_firestore.dart';

class CallSession {
  final String docId;
  final String callId;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String type; // 'audio' or 'video'
  final String status; // 'ringing', 'accepted', 'rejected', 'ended'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CallSession({
    this.docId = '',
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.type,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'type': type,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory CallSession.fromMap(Map<String, dynamic> map, String docId) {
    return CallSession(
      docId: docId,
      callId: map['callId'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      type: map['type'] ?? 'video',
      status: map['status'] ?? 'ringing',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
