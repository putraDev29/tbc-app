import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbc_digital_app/screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Map<String, dynamic>? detail;

  double? bmi;
  double? bb;
  double? tb;
  int age = 0;
  String statusGizi = "-";
  String statusPengobatan = "Aktif"; // 🔥 default

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  /// 🔥 HITUNG UMUR
  int hitungUmur(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return 0;

    DateTime dob = DateTime.parse(birthDate);
    DateTime now = DateTime.now();

    int umur = now.year - dob.year;

    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      umur--;
    }

    return umur;
  }

  /// 🔥 STATUS GIZI
  String getStatusGizi(double bmi, int age) {
    if (age >= 5 && age <= 18) {
      return getStatusGiziAnak(bmi, age);
    } else {
      return getStatusGiziDewasa(bmi);
    }
  }

  String getStatusGiziDewasa(double bmi) {
    if (bmi < 18.5) {
      return "Berat badan kurang";
    } else if (bmi < 23) {
      return "Normal";
    } else if (bmi < 25) {
      return "Overweight";
    } else if (bmi < 30) {
      return "Obesitas I";
    } else {
      return "Obesitas II";
    }
  }

  String getStatusGiziAnak(double bmi, int age) {
    double z = bmi / age;

    if (z >= -3 && z < -2) {
      return "Gizi Kurang";
    } else if (z >= -2 && z <= 1) {
      return "Normal";
    } else if (z > 1 && z <= 2) {
      return "Gizi Lebih";
    } else if (z > 2) {
      return "Obesitas";
    } else {
      return "Gizi Buruk";
    }
  }

  /// 🔥 COLOR STATUS GIZI
  Color getStatusGiziColor(String status) {
    switch (status) {
      case "Normal":
        return Colors.green;

      case "Berat badan kurang":
      case "Gizi Kurang":
      case "Gizi Buruk":
        return Colors.orange;

      case "Overweight":
      case "Gizi Lebih":
        return Colors.deepOrange;

      case "Obesitas I":
      case "Obesitas II":
      case "Obesitas":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  /// 🔥 LOAD DATA
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    String? detailStr = prefs.getString("detail");
    String? jsonString = prefs.getString("data");

    String? endDateStr = prefs.getString("end_date");

    /// 🔥 PARSE DATE
    DateTime? endDate = endDateStr != null
        ? DateTime.tryParse(endDateStr)
        : null;

    statusPengobatan = getStatusPengobatan(endDate);

    /// BMI TERAKHIR
    if (jsonString != null) {
      final jsonData = jsonDecode(jsonString);
      final health = jsonData['health'];

      List<dynamic> list = health['week'] ?? [];

      if (list.isNotEmpty) {
        final last = list.last;

        bmi = (last['bmi'] as num?)?.toDouble();
        bb = (last['weight'] as num?)?.toDouble();
        tb = (last['height'] as num?)?.toDouble();
      }
    }

    /// DETAIL + UMUR + STATUS GIZI
    if (detailStr != null) {
      final d = jsonDecode(detailStr);

      age = hitungUmur(d['date_born']);

      if (bmi != null && age > 0) {
        statusGizi = getStatusGizi(bmi!, age);
      }

      setState(() {
        detail = d;
      });
    }
  }

  /// STATUS COLOR
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "patuh":
        return Colors.green;
      case "terlambat":
        return Colors.orange;
      case "tidak patuh":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (detail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final p = {
      "nama": detail!['name'] ?? "-",
      "umur": age > 0 ? age.toString() : "-",
      "tb": tb != null ? tb!.toStringAsFixed(0) : "-",
      "bb": bb != null ? bb!.toStringAsFixed(0) : "-",
      "bmi": bmi != null ? bmi!.toStringAsFixed(2) : "-",
      "status_gizi": statusGizi,
      "alamat": detail!['address'] ?? "-",
      "status_pengobatan": statusPengobatan,
    };

    final giziColor = getStatusGiziColor(p['status_gizi']!);
    final pengobatanColor = getStatusPengobatanColor(p['status_pengobatan']!);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          "Profil Pasien",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7FB77E),
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// HEADER
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7FB77E), Color(0xFF9ED69E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF7FB77E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p['nama']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// INFO
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    profileItem(Icons.cake, "Umur", "${p['umur']} Tahun"),
                    const Divider(),
                    profileItem(Icons.straighten, "Tinggi", "${p['tb']} cm"),
                    const Divider(),
                    profileItem(Icons.fitness_center, "Berat", "${p['bb']} kg"),
                    const Divider(),
                    profileItem(Icons.monitor_heart, "BMI", p['bmi']!),
                    const Divider(),

                    /// 🔥 STATUS GIZI
                    profileItem(
                      Icons.health_and_safety,
                      "Status Gizi",
                      p['status_gizi']!,
                      valueColor: giziColor,
                    ),
                    const Divider(),

                    profileItem(
                      Icons.health_and_safety,
                      "Status Pengobatan",
                      p['status_pengobatan']!,
                      valueColor: pengobatanColor,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: logout,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        "Keluar",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileItem(
    IconData icon,
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7FB77E)),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  /// 🔥 STATUS PENGOBATAN (AKTIF / TIDAK)
  String getStatusPengobatan(DateTime? endDate) {
    if (endDate == null) return "Aktif";

    DateTime today = DateTime.now();

    if (today.isAfter(endDate)) {
      return "Tidak Aktif";
    }

    return "Aktif";
  }

  Color getStatusPengobatanColor(String status) {
    switch (status) {
      case "Aktif":
        return Colors.green;
      case "Tidak Aktif":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    /// =========================
    /// 🔥 HAPUS FCM
    /// =========================
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // hapus token
      await messaging.deleteToken();

      // unsubscribe topic (optional, kalau dipakai)
      await messaging.unsubscribeFromTopic("all");
    } catch (e) {
      print("Error FCM logout: $e");
    }

    /// =========================
    /// 🔥 HAPUS LOCAL NOTIFICATION
    /// =========================
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print("Error notif clear: $e");
    }

    /// =========================
    /// 🔥 CLEAR STORAGE
    /// =========================
    await prefs.clear();

    /// =========================
    /// 🔥 NAVIGATE
    /// =========================
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
