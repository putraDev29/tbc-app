import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';
import 'api_constant.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  /// ================= DASHBOARD =================
  static Future<DashboardModel> getDashboard(int patientId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/patient/$patientId/dashboard"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return DashboardModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal load dashboard");
    }
  }

  /// ================= UPLOAD OBAT =================
  static Future<bool> uploadObat(
      int patientId,
      String status,
      String filePath,
      ) async {

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/patient/$patientId/take-medicine"),
    );

    request.fields['status'] = status;

    if (filePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('image', filePath),
      );
    }

    var response = await request.send();

    return response.statusCode == 200;
  }
}