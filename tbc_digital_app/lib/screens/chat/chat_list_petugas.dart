import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'chat_screen_petugas.dart';

class ChatListPetugas extends StatefulWidget {
  const ChatListPetugas({super.key});

  @override
  State<ChatListPetugas> createState() => _ChatListPetugasState();
}

class _ChatListPetugasState extends State<ChatListPetugas> {
  final String officerId = "2";

  /// ================= UNREAD COUNT =================
  Future<int> getUnreadCount(String roomId, String patientId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('is_read', isEqualTo: false)
        .get();

    final unreadFromPatient = snapshot.docs.where((doc) {
      return doc['sender_id'].toString() == patientId;
    }).toList();

    return unreadFromPatient.length;
  }

  /// ================= MARK AS READ =================
  Future<void> markAsRead(String roomId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final senderId = doc['sender_id'].toString();

      // hanya pesan dari pasien
      if (senderId != officerId) {
        await doc.reference.update({
          'is_read': true,
        });
      }
    }
  }

  /// ================= REFRESH UI =================
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Pasien"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('officer_id', isEqualTo: officerId)
            .orderBy('last_time', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi error"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Belum ada chat pasien"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final roomId = docs[index].id;
              final patientId = data['patient_id'].toString();
              final patientName = data['patient_name'] ?? 'Pasien';
              final lastMessage = data['last_message'] ?? '';

              return FutureBuilder<int>(
                future: getUnreadCount(roomId, patientId),
                builder: (context, snapshotUnread) {
                  final unreadCount = snapshotUnread.data ?? 0;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: unreadCount > 0
                          ? AppColors.primaryUltraLight
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          patientName.isNotEmpty
                              ? patientName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      title: Text(
                        patientName,
                        style: TextStyle(
                          fontWeight: unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),

                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),

                      trailing: unreadCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const Icon(Icons.chevron_right),

                      onTap: () async {
                        final roomId = docs[index].id;

                        // 🔥 MARK AS READ
                        await markAsRead(roomId);

                        // 🔥 OPEN CHAT
                        if (!context.mounted) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreenPetugas(
                              patientUserId: patientId,
                              patientName: patientName,
                            ),
                          ),
                        );

                        // 🔥 REFRESH SAAT BALIK
                        refresh();
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

