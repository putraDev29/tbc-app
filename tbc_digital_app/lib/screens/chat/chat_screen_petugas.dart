import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/chat_message_model.dart';
import '../../services/chat_service.dart';
import '../../components/chat/chat_bubble.dart';

class ChatScreenPetugas extends StatefulWidget {
  final String patientUserId;
  final String patientName;

  const ChatScreenPetugas({
    super.key,
    required this.patientUserId,
    required this.patientName,
  });

  @override
  State<ChatScreenPetugas> createState() => _ChatScreenPetugasState();
}

class _ChatScreenPetugasState extends State<ChatScreenPetugas> {
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String officerId = "2";

  /// ================= ROOM ID (WAJIB SAMA DENGAN SERVICE) =================
  String get roomId =>
      _chatService.generateRoomId(officerId, widget.patientUserId);

  @override
  void initState() {
    super.initState();
    markAsRead();
  }

  /// ================= MARK AS READ =================
  Future<void> markAsRead() async {
    await _chatService.markAsRead(roomId, officerId);
  }

  /// ================= AUTO SCROLL =================
  void scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// ================= SEND MESSAGE =================
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();

    await _chatService.sendMessage(
      senderId: officerId,
      receiverId: widget.patientUserId,
      message: text,
      senderName: "Petugas",
      receiverName: widget.patientName,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          /// ================= CHAT LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(roomId)
                  .collection('messages')
                  .orderBy('created_at')
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                /// auto scroll hanya kalau data berubah
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final chat = ChatMessageModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                    );

                    return ChatBubble(
                      chat: chat,
                      isMe: chat.senderId == officerId,
                    );
                  },
                );
              },
            ),
          ),

          /// ================= INPUT =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
            ),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Tulis pesan...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

