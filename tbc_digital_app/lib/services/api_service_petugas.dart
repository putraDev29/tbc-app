import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_constant.dart';

class ApiServicePetugas {
  static const baseUrl = ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> getDashboardPetugas({
    int? villageId,
  }) async {
    final url = villageId == null
        ? "$baseUrl/dashboard-petugas"
        : "$baseUrl/dashboard-petugas?village_id=$villageId";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Gagal load dashboard petugas");
    }
  }

  static Future<List<dynamic>> getVillages() async {
    final res = await http.get(Uri.parse("$baseUrl/villages"));

    return jsonDecode(res.body)['data'];
  }

  static Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int limit = 5,
    int? villageId,
  }) async {
    final queryParams = {
      "page": "$page",
      "limit": "$limit",
      if (villageId != null) "village_id": "$villageId",
    };

    final uri = Uri.parse(
      "$baseUrl/patients",
    ).replace(queryParameters: queryParams);

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      return {"data": data["data"], "meta": data["meta"]};
    } else {
      throw Exception("Failed load patients");
    }
  }

  static Future<bool> createPatient(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/patient"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      print(response.body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR CREATE PATIENT: $e");
      return false;
    }
  }

  static Future<bool> updatePatient(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/patient/$id"), // 🔥 endpoint update
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      print("UPDATE RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("ERROR UPDATE PATIENT: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getPending() async {
    final res = await http.get(Uri.parse("$baseUrl/medication-log/pending"));

    if (res.statusCode == 200) {
      print(res.body);
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<bool> approve(int id) async {
    final res = await http.post(
      Uri.parse("$baseUrl/medication-log/$id/approve"),
    );
    return res.statusCode == 200;
  }

  static Future<bool> reject(int id) async {
    final res = await http.post(
      Uri.parse("$baseUrl/medication-log/$id/reject"),
    );
    return res.statusCode == 200;
  }

  static Future<dynamic> getPatientsByStatus(String status) async {
    final response = await http.get(
      Uri.parse("$baseUrl/patients/status/$status"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body);
  }
}
