import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/app_constants.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  // ================= INIT =================
  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('ic_notification');

    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    final androidPlatform = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // 1. CHANNEL OBAT (Custom Sound: notif_sound.mp3)
    const medicineChannel = AndroidNotificationChannel(
      AppConstants.medicineChannelId,
      AppConstants.medicineChannelName,
      description: AppConstants.medicineChannelDesc,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(AppConstants.medicineSoundName),
    );

    // 2. CHANNEL CHAT (Default Sound)
    const chatChannel = AndroidNotificationChannel(
      AppConstants.chatChannelId,
      AppConstants.chatChannelName,
      description: AppConstants.chatChannelDesc,
      importance: Importance.high,
      playSound: true,
    );

    await androidPlatform?.createNotificationChannel(medicineChannel);
    await androidPlatform?.createNotificationChannel(chatChannel);
  }

  // ================= SHOW NOTIF =================
  static Future<void> showNotification(RemoteMessage message) async {
    final type = (message.data['type'] ?? '').toString().toLowerCase();
    final bool isChat = type == 'chat';

    AndroidNotificationDetails androidDetails;

    if (isChat) {
      // Chat -> Suara Default
      androidDetails = const AndroidNotificationDetails(
        AppConstants.chatChannelId,
        AppConstants.chatChannelName,
        channelDescription: AppConstants.chatChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: 'ic_notification',
      );
    } else {
      // Minum Obat -> Suara Kustom (notif_sound)
      androidDetails = const AndroidNotificationDetails(
        AppConstants.medicineChannelId,
        AppConstants.medicineChannelName,
        channelDescription: AppConstants.medicineChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(AppConstants.medicineSoundName),
        icon: 'ic_notification',
      );
    }

    final details = NotificationDetails(android: androidDetails);

    final title = message.notification?.title ??
        message.data['title'] ??
        (isChat ? 'Pesan Baru' : 'Notifikasi TBC');

    final body = message.notification?.body ??
        message.data['message'] ??
        message.data['body'] ??
        '';

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: message.data.toString(),
    );
  }
}
