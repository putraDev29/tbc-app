import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '/services/local_notification_service.dart';
import 'api_constant.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String baseUrl = ApiConstants.baseUrl;

  Future<void> initFCM(int userId) async {
    // permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // token awal
    String? token;
    try {
      token = await _messaging.getToken();
    } catch (e) {
      print("Error get FCM token: $e");
    }
    print("FCM TOKEN: $token");

    if (token != null) {
      await sendFcmToken(token, userId);
    }

    // 🔥 listener token refresh jika token diperbarui Firebase
    _messaging.onTokenRefresh.listen((newToken) {
      print("FCM TOKEN REFRESH: $newToken");
      sendFcmToken(newToken, userId);
    });

    // FOREGROUND
    FirebaseMessaging.onMessage.listen((message) {
      print("RAW DATA: ${message.data}");
      print("NOTIF: ${message.notification}");

      if (!kIsWeb) {
        LocalNotificationService.showNotification(message);
      }
    });

    // CLICK NOTIF
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("NOTIF DIKLIK: ${message.data}");
    });
  }

  static Future<bool> sendFcmToken(String token, int userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/save-fcm-token"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // 🔥 penting supaya tidak redirect HTML
        },
        body: jsonEncode({
          "user_id": userId,
          "fcm_token": token,
          "device": kIsWeb ? "web" : "android",
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR SEND FCM TOKEN: $e");
      return false;
    }
  }
}
