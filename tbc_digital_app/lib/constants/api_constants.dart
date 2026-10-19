class ApiConstants {
  ApiConstants._();

  // Base URL (Production Hosting)
  static const String baseUrl = 'https://amiitrans.com/tbc/api';
  static const String storageUrl = 'https://amiitrans.com/tbc/storage';

  // Base URL (Lokal Pengembangan / Emulator)
  // static const String baseUrl = 'http://172.16.55.214:8000/api';
  // static const String storageUrl = 'http://172.16.55.214:8000/storage';

  // Auth Endpoints
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';

  // FCM & Notification Endpoints
  static const String saveFcmToken = '$baseUrl/save-fcm-token';
  static const String deleteFcmToken = '$baseUrl/delete-fcm-token';
  static const String sendChatNotification = '$baseUrl/send-chat-notification';

  // Patient Endpoints
  static const String patientDashboard = '$baseUrl/patient/dashboard';
  static const String submitMedication = '$baseUrl/patient/medication';

  // Petugas Endpoints
  static const String petugasDashboard = '$baseUrl/petugas/dashboard';
  static const String listPasien = '$baseUrl/petugas/patients';
  static const String validasiObat = '$baseUrl/petugas/validasi-obat';

  // Manajemen / Kapus Endpoints
  static const String manajemenDashboard = '$baseUrl/manajemen/dashboard';
}

