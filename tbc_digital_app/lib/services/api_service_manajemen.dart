import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constant.dart';

class ApiServiceManajemen {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> fetchDashboard({
    required int year,
    required int month,
    required String desa,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/dashboard-manajemen?year=$year&month=$month&desa=$desa",
      ),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // 🔥 VALIDASI WAJIB
      if (body is Map<String, dynamic>) {
        return body;
      } else {
        throw Exception("Response bukan Map");
      }
    } else {
      throw Exception("Gagal ambil data");
    }
  }
}
