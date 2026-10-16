import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel chat;
  final bool isMe;

  const ChatBubble({super.key, required this.chat, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat.message,
              style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(chat.createdAt.toDate()),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

