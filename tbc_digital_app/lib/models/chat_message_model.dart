import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp createdAt;
  final bool isRead;

  const ChatMessageModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      senderId: map['sender_id']?.toString() ?? '',
      receiverId: map['receiver_id']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      createdAt: map['created_at'] is Timestamp ? map['created_at'] : Timestamp.now(),
      isRead: map['is_read'] ?? false,
    );
  }
}

