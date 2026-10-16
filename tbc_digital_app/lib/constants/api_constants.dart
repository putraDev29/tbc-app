class ApiConstants {
  ApiConstants._();

  // Base URL
  // static const String baseUrl = 'https://tbc.amiitrans.com/api';
  static const String baseUrl = 'http://172.16.55.214:8000/api';

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

