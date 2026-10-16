import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class FcmChatService {
  FcmChatService._();

  static Future<void> sendPushToReceiver({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String message,
    required String role,
  }) async {
    try {
      await http.post(
        Uri.parse(ApiConstants.sendChatNotification),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'sender_id': int.tryParse(senderId) ?? senderId,
          'receiver_id': int.tryParse(receiverId) ?? receiverId,
          'sender_name': senderName,
          'message': message,
          'role': role,
        }),
      );
    } catch (_) {
      // Ignore network push failure so chat messaging continues smoothly
    }
  }
}

