import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/chat_message_model.dart';
import '../../services/chat_service.dart';
import '../../components/chat/chat_bubble.dart';

class ChatScreenPasien extends StatefulWidget {
  final String receiverId;

  const ChatScreenPasien({super.key, required this.receiverId});

  @override
  State<ChatScreenPasien> createState() => _ChatScreenPasienState();
}

class _ChatScreenPasienState extends State<ChatScreenPasien> {
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String myUserId = "";
  String myName = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  /// ================= LOAD USER =================
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString(AppConstants.keyUser);
    final detailString = prefs.getString("detail");

    if (userString == null || detailString == null) return;

    final user = jsonDecode(userString);
    final detail = jsonDecode(detailString);

    if (!mounted) return;
    setState(() {
      myUserId = user['id'].toString();
      myName = detail['name'] ?? 'Pasien';
    });
  }

  /// ================= ROOM ID =================
  String get roomId => _chatService.generateRoomId(myUserId, widget.receiverId);

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
      senderId: myUserId,
      receiverId: widget.receiverId,
      message: text,
      senderName: myName,
      receiverName: "Petugas",
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (myUserId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Petugas"),
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
                      isMe: chat.senderId == myUserId,
                    );
                  },
                );
              },
            ),
          ),

          /// ================= INPUT =================
          SafeArea(
            top: false,
            child: Container(
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
                        hintText: "Ketik pesan...",
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

