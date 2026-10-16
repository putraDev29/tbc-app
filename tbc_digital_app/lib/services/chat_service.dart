import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';
import 'fcm_chat_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= ROOM ID =================
  String generateRoomId(String userA, String userB) {
    final ids = [userA, userB];
    ids.sort();
    return "room_${ids[0]}_${ids[1]}";
  }

  /// ================= SEND MESSAGE =================
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    required String senderName, // 🔥 penting untuk chat list
    required String receiverName,
  }) async {
    final roomId = generateRoomId(senderId, receiverId);

    final msg = ChatMessageModel(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      createdAt: Timestamp.now(),
      isRead: false,
    );

    /// ================= SAVE MESSAGE =================
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add(msg.toMap());

    /// ================= UPDATE CHAT ROOM =================
    await _firestore.collection('chat_rooms').doc(roomId).set({
      'room_id': roomId,

      /// 👇 penting untuk list petugas
      'patient_id': senderId == "2" ? receiverId : senderId,
      'patient_name': senderId == "2" ? receiverName : senderName,

      'officer_id': "2",

      /// last message preview
      'last_message': message,
      'last_time': FieldValue.serverTimestamp(),

      /// future feature
      'is_typing': false,
      'unread_count': FieldValue.increment(1),
    }, SetOptions(merge: true));

    /// ================= PUSH NOTIF =================
    await FcmChatService.sendPushToReceiver(
      senderId: senderId,
      receiverId: receiverId,
      senderName: senderName,
      message: message,
      role: senderId == "2" ? "petugas" : "pasien",
    );
  }

  /// ================= GET MESSAGES =================
  Stream<QuerySnapshot> getMessages(String myId, String otherId) {
    final roomId = generateRoomId(myId, otherId);

    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('created_at', descending: false)
        .snapshots();
  }

  /// ================= CHAT LIST PETUGAS =================
  Stream<QuerySnapshot> getChatListPetugas() {
    return _firestore
        .collection('chat_rooms')
        .where('officer_id', isEqualTo: "2")
        .orderBy('last_time', descending: true)
        .snapshots();
  }

  /// ================= MARK AS READ =================
  Future<void> markAsRead(String roomId, String officerId) async {
    final snapshot = await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      if (doc['sender_id'].toString() != officerId) {
        await doc.reference.update({'is_read': true});
      }
    }
  }
}

