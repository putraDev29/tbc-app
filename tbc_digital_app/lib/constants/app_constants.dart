class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'TBC Digital App';
  static const String appVersion = '1.0.0';

  // Notification Channel IDs
  static const String medicineChannelId = 'channel_medicine_v1';
  static const String medicineChannelName = 'Pengingat Minum Obat';
  static const String medicineChannelDesc = 'Channel khusus pengingat waktu minum obat TBC dan status validasi';
  static const String medicineSoundName = 'notif_sound';

  static const String chatChannelId = 'channel_chat_v1';
  static const String chatChannelName = 'Notifikasi Chat';
  static const String chatChannelDesc = 'Channel notifikasi pesan masuk dari petugas dan pasien';

  // SharedPreferences Keys
  static const String keyUser = 'user';
  static const String keyToken = 'token';
  static const String keyFcmToken = 'fcm_token';

  // Roles
  static const String rolePasien = 'pasien';
  static const String rolePetugas = 'petugas';
  static const String roleManajemen = 'manajemen';
}

